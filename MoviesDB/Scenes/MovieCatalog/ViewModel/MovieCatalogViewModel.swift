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

    private(set) var state = MovieCatalogViewModelState()

    private let kind: Kind
    private let moviesService: MoviesServiceProtocol
    private let watchlistStore: WatchlistStoreProtocol
    private let mapper: MovieCatalogViewModelMapper
    private let posterPrefetchController: any PosterPrefetchControlling
    private let language: String

    @ObservationIgnored private var currentTask: Task<Void, Never>?
    @ObservationIgnored private var watchlistTask: Task<Void, Never>?

    var title: String {
        Constants.title(for: kind, count: state.items.count)
    }

    func isInWatchlist(id: Int) -> Bool {
        state.watchlistIds.contains(id)
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
        guard state.currentPage == 0, currentTask == nil else { return }
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
        state.movies[safe: index]
    }

    func toggleWatchlist(at index: Int) {
        guard let movie = state.movies[safe: index] else { return }
        Task {
            await watchlistStore.toggle(movie: movie)
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        guard currentTask == nil, state.hasMoreItems else { return }
        let nextBatchThreshold = max(state.movies.count - Constants.loadMoreThreshold, Constants.loadMoreThreshold)
        if currentIndex >= nextBatchThreshold {
            loadNextPage()
        }
    }

    func dismissError() {
        state.phase = .idle
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
        state.visibleColumns = columns
        reportItemsCount()
    }

    private func reportItemsCount() {
        let posterURLs = state.items.map(\.posterURL)
        let itemsCount = posterURLs.count
        let visibleColumns = state.visibleColumns
        Task { [posterPrefetchController] in
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
        let nextPage = state.currentPage + 1
        if state.currentPage == 0 {
            await fetchInitialPages(startingAt: nextPage)
        } else {
            await fetchPageAndUpdate(page: nextPage)
        }
    }

    private func fetchPageAndUpdate(page: Int) async {
        do {
            guard !Task.isCancelled else { return }
            setLoadingState(isInitial: state.currentPage == 0)
            let previousCount = state.movies.count
            let response = try await fetchPage(page: page)
            state.currentPage = response.page
            state.totalPages = response.totalPages
            state.movies = appendUniqueMovies(existing: state.movies, incoming: response.results)
            updateItems(previousCount: previousCount)
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
            let previousCount = state.movies.count

            var updatedMovies = state.movies
            var updatedCurrentPage = state.currentPage
            var updatedTotalPages = state.totalPages

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

            state.currentPage = updatedCurrentPage
            state.totalPages = updatedTotalPages
            state.movies = updatedMovies
            updateItems(previousCount: previousCount)
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
        state.phase = isInitial ? .initialLoading : .loadingMore
        reportItemsCount()
    }

    private func clearLoadingState() {
        state.phase = .idle
        reportItemsCount()
    }

    private func setError(_ error: Error) {
        let details = MovieCatalogErrorState(
            message: error.localizedDescription,
            retry: { [weak self] in
                self?.loadNextPage()
            }
        )
        state.phase = .error(details)
        reportItemsCount()
    }

    private func updateItems(previousCount: Int? = nil) {
        if let previousCount, canAppendItems(from: previousCount) {
            appendItems(from: previousCount)
        } else {
            let loaded = LoadedMovieList(movies: state.movies, watchlistIds: state.watchlistIds)
            state.items = mapper.makeMovies(from: loaded)
            reportItemsCount()
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
            guard updatedIds != state.watchlistIds else { continue }
            let previousIds = state.watchlistIds
            state.watchlistIds = updatedIds
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
        guard state.items.count == state.movies.count else {
            updateItems()
            return
        }

        let movieIndexByID = Self.makeMovieIndexMap(from: state.movies)
        var updatedItems = state.items
        for id in changedIDs {
            guard let index = movieIndexByID[id], let movie = state.movies[safe: index] else { continue }
            updatedItems[index] = mapper.makeMovie(movie: movie, isInWatchlist: updatedIDs.contains(id))
        }
        state.items = updatedItems
        reportItemsCount()
    }

    private static func makeMovieIndexMap(from movies: [Movie]) -> [Int: Int] {
        Dictionary(uniqueKeysWithValues: movies.enumerated().map { ($1.id, $0) })
    }

    private func canAppendItems(from previousCount: Int) -> Bool {
        guard previousCount >= 0, previousCount <= state.movies.count else { return false }
        guard state.items.count == previousCount else { return false }
        guard previousCount > 0 else { return true }
        for index in 0..<previousCount where state.items[index].id != String(state.movies[index].id) {
            return false
        }
        return true
    }

    private func appendItems(from previousCount: Int) {
        guard previousCount < state.movies.count else { return }
        let appended = state.movies[previousCount...].map { movie in
            mapper.makeMovie(movie: movie, isInWatchlist: state.watchlistIds.contains(movie.id))
        }
        state.items.append(contentsOf: appended)
        reportItemsCount()
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
