import Foundation
import MovieDBData
import MovieDBUI
import Observation

@MainActor
@Observable
final class MovieCatalogViewModel: MovieCatalogViewModelProtocol {
    enum Kind {
        case popular
        case topRated
    }

    private(set) var state: MovieCatalogViewModelState = .idle(items: [])

    private let kind: Kind
    private let moviesService: MoviesServiceProtocol
    private let watchlistStore: WatchlistStoreProtocol
    private let mapper: MovieCatalogViewModelMapper
    private let posterPrefetchController: any PosterPrefetchControlling
    private let language: String

    @ObservationIgnored private var currentTask: Task<Void, Never>?
    @ObservationIgnored private var watchlistTask: Task<Void, Never>?
    @ObservationIgnored private var movies: [Movie] = []
    @ObservationIgnored private var movieIndexByID: [Int: Int] = [:]
    @ObservationIgnored private var watchlistIds: Set<Int> = []
    @ObservationIgnored private var currentPage = 0
    @ObservationIgnored private var totalPages = 1
    @ObservationIgnored private var visibleColumns = 1
    @ObservationIgnored private var lastReportedItemsCount: Int?

    var title: String {
        Constants.title(for: kind, count: state.items.count)
    }

    func isInWatchlist(id: Int) -> Bool {
        watchlistIds.contains(id)
    }

    init(
        kind: Kind,
        moviesService: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        posterPrefetchController: any PosterPrefetchControlling,
        language: String = Locale.current.language.languageCode?.identifier ?? Constants.en
    ) {
        self.kind = kind
        self.moviesService = moviesService
        self.watchlistStore = watchlistStore
        self.mapper = MovieCatalogViewModelMapper(uiAssets: uiAssets)
        self.posterPrefetchController = posterPrefetchController
        self.language = language
    }

    func onAppear() {
        startWatchlistObservationIfNeeded()
        guard currentPage == 0, currentTask == nil else { return }
        loadNextPage()
    }

    func onDisappear() {
        currentTask?.cancel()
        watchlistTask?.cancel()
        watchlistTask = nil
        Task { [posterPrefetchController] in
            await posterPrefetchController.stop()
        }
    }

    func movie(at index: Int) -> Movie? {
        movies[safe: index]
    }

    func toggleWatchlist(at index: Int) {
        guard let movie = movies[safe: index] else { return }
        Task {
            await watchlistStore.toggle(movie: movie)
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentTask == nil, hasMoreItems else { return }
        let nextBatchThreshold = max(movies.count - Constants.loadMoreThreshold, Constants.loadMoreThreshold)
        if currentIndex >= nextBatchThreshold {
            loadNextPage()
        }
    }

    func dismissError() {
        state = .idle(items: state.items)
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int) {
        let posterURLs = state.items.map(\.posterURL)
        let itemCount = posterURLs.count
        Task { [posterPrefetchController] in
            await posterPrefetchController.itemVisibilityChanged(
                index: index,
                isVisible: isVisible,
                columns: columns,
                itemCount: itemCount,
                posterURLAt: { index in
                    guard posterURLs.indices.contains(index) else { return nil }
                    return posterURLs[index]
                }
            )
        }
    }

    func updateVisibleColumns(_ columns: Int) {
        guard columns > 0 else { return }
        let didChange = visibleColumns != columns
        visibleColumns = columns
        reportItemsCountIfNeeded(force: didChange)
    }

    private func reportItemsCountIfNeeded(force: Bool = false) {
        let posterURLs = state.items.map(\.posterURL)
        let itemsCount = posterURLs.count
        guard force || lastReportedItemsCount != itemsCount else { return }
        lastReportedItemsCount = itemsCount
        Task { [posterPrefetchController, visibleColumns] in
            await posterPrefetchController.itemCountChanged(
                columns: visibleColumns,
                itemCount: itemsCount,
                posterURLAt: { index in
                    guard posterURLs.indices.contains(index) else { return nil }
                    return posterURLs[index]
                }
            )
        }
    }

    private var hasMoreItems: Bool {
        currentPage < totalPages
    }

    private func loadNextPage() {
        guard currentTask == nil else { return }
        currentTask = Task { [weak self] in
            await self?.performLoadNextPage()
            await MainActor.run { [weak self] in
                self?.currentTask = nil
            }
        }
    }

    private func performLoadNextPage() async {
        let nextPage = currentPage + 1
        if currentPage == 0 {
            await fetchInitialPages(startingAt: nextPage)
        } else {
            await fetchPageAndUpdate(page: nextPage)
        }
    }

    private func fetchPageAndUpdate(page: Int) async {
        do {
            guard !Task.isCancelled else { return }
            setLoadingState(isInitial: currentPage == 0)
            let previousCount = movies.count
            let response = try await fetchPage(page: page)
            currentPage = response.page
            totalPages = response.totalPages
            movies = appendUniqueMovies(existing: movies, incoming: response.results)
            movieIndexByID = Self.makeMovieIndexMap(from: movies)
            updateItemsAndTitle(previousCount: previousCount)
            clearLoadingState()
        } catch {
            clearLoadingState()
            setError(error)
        }
    }

    private func fetchInitialPages(startingAt page: Int) async {
        do {
            guard !Task.isCancelled else { return }
            setLoadingState(isInitial: true)
            let previousCount = movies.count

            var updatedMovies = movies
            var updatedCurrentPage = currentPage
            var updatedTotalPages = totalPages

            for index in 0..<Constants.initialPagesToLoad {
                let targetPage = page + index
                let response = try await fetchPage(page: targetPage)
                updatedCurrentPage = response.page
                updatedTotalPages = response.totalPages
                updatedMovies = appendUniqueMovies(existing: updatedMovies, incoming: response.results)
                if response.results.isEmpty || updatedCurrentPage >= updatedTotalPages {
                    break
                }
            }

            currentPage = updatedCurrentPage
            totalPages = updatedTotalPages
            movies = updatedMovies
            movieIndexByID = Self.makeMovieIndexMap(from: movies)
            updateItemsAndTitle(previousCount: previousCount)
            clearLoadingState()
        } catch {
            clearLoadingState()
            setError(error)
        }
    }

    private func fetchPage(page: Int) async throws -> MovieList {
        switch kind {
        case .popular:
            return try await moviesService.fetchPopular(options: .init(page: page, language: language))
        case .topRated:
            return try await moviesService.fetchTopRated(options: .init(page: page, language: language))
        }
    }

    private func setLoadingState(isInitial: Bool) {
        state = isInitial ? .initialLoading(items: state.items) : .loadingMore(items: state.items)
        reportItemsCountIfNeeded()
    }

    private func clearLoadingState() {
        state = .idle(items: state.items)
        reportItemsCountIfNeeded()
    }

    private func setError(_ error: Error) {
        let details = MovieCatalogErrorState(
            message: error.localizedDescription,
            retry: { [weak self] in
                self?.loadNextPage()
            }
        )
        state = .error(items: state.items, details: details)
        reportItemsCountIfNeeded()
    }

    private func updateItemsAndTitle(previousCount: Int? = nil) {
        if let previousCount, canAppendItems(from: previousCount) {
            appendItems(from: previousCount)
        } else {
            let loaded = LoadedMovieList(movies: movies, watchlistIds: watchlistIds)
            state = state.replacingItems(mapper.makeMovies(from: loaded))
            reportItemsCountIfNeeded()
        }
    }

    private func startWatchlistObservationIfNeeded() {
        guard watchlistTask == nil else { return }
        watchlistTask = Task { [weak self] in
            await self?.observeWatchlist()
        }
    }

    private func observeWatchlist() async {
        let stream = await watchlistStore.itemsStream()
        for await items in stream {
            let updatedIds = Set(items.map(\.id))
            guard updatedIds != watchlistIds else { continue }
            let previousIds = watchlistIds
            watchlistIds = updatedIds
            applyWatchlistDelta(previousIDs: previousIds, updatedIDs: updatedIds)
        }
    }

    private func appendUniqueMovies(existing: [Movie], incoming: [Movie]) -> [Movie] {
        var merged = existing
        var seen = Set(existing.map(\.id))
        for movie in incoming where seen.insert(movie.id).inserted {
            merged.append(movie)
        }
        return merged
    }

    private func applyWatchlistDelta(previousIDs: Set<Int>, updatedIDs: Set<Int>) {
        let changedIDs = previousIDs.symmetricDifference(updatedIDs)
        guard !changedIDs.isEmpty else { return }
        guard state.items.count == movies.count else {
            updateItemsAndTitle()
            return
        }

        var updatedItems = state.items
        for id in changedIDs {
            guard let index = movieIndexByID[id], let movie = movies[safe: index] else { continue }
            updatedItems[index] = mapper.makeMovie(movie: movie, isInWatchlist: updatedIDs.contains(id))
        }
        state = state.replacingItems(updatedItems)
        reportItemsCountIfNeeded()
    }

    private static func makeMovieIndexMap(from movies: [Movie]) -> [Int: Int] {
        Dictionary(uniqueKeysWithValues: movies.enumerated().map { ($1.id, $0) })
    }

    private func canAppendItems(from previousCount: Int) -> Bool {
        guard previousCount >= 0, previousCount <= movies.count else { return false }
        guard state.items.count == previousCount else { return false }
        guard previousCount > 0 else { return true }
        for index in 0..<previousCount where state.items[index].id != String(movies[index].id) {
            return false
        }
        return true
    }

    private func appendItems(from previousCount: Int) {
        guard previousCount < movies.count else { return }
        let appended = movies[previousCount...].map { movie in
            mapper.makeMovie(movie: movie, isInWatchlist: watchlistIds.contains(movie.id))
        }
        var updatedItems = state.items
        updatedItems.append(contentsOf: appended)
        state = state.replacingItems(updatedItems)
        reportItemsCountIfNeeded()
    }
}

private struct LoadedMovieList: MovieCatalogLoadedState {
    let movies: [Movie]
    let watchlistIds: Set<Int>
}

private enum Constants {
    static let loadMoreThreshold = 20
    static let initialPagesToLoad = 2
    static let en = "en"

    static func title(for kind: MovieCatalogViewModel.Kind, count: Int) -> String {
        switch kind {
        case .popular:
            return String(format: String.localizable.popularCountTitle, count)
        case .topRated:
            return String(format: String.localizable.topRatedCountTitle, count)
        }
    }
}
