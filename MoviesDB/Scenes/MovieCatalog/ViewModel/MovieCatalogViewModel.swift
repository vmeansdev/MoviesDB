import MovieDBData
import MovieDBUI
import Observation
import SwiftUI
import UIKit

@MainActor
@Observable
final class MovieCatalogViewModel: MovieCatalogViewModelProtocol {
    enum Kind {
        case popular
        case topRated
    }

    private(set) var title: String
    private(set) var items: [MovieCollectionViewModel] = []
    private(set) var error: MovieCatalogErrorState?
    private(set) var isInitialLoading = false
    private(set) var isLoadingMore = false

    private let kind: Kind
    private let moviesService: MoviesServiceProtocol
    private let watchlistStore: WatchlistStoreProtocol
    private let mapper: MovieCatalogViewModelMapper
    private let posterPrefetchController: any PosterPrefetchControlling
    private let language: String

    private var currentTask: Task<Void, Never>?
    private var watchlistTask: Task<Void, Never>?
    private var movies: [Movie] = []
    private var movieIndexByID: [Int: Int] = [:]
    private var watchlistIds: Set<Int> = []
    private var currentPage = 0
    private var totalPages = 1
    private var hasLoadedInitial = false
    private var isLoading = false

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
        self.title = Constants.title(for: kind, count: 0)
    }

    func onAppear() {
        startWatchlistObservationIfNeeded()
        guard !hasLoadedInitial else { return }
        hasLoadedInitial = true
        loadNextPage()
    }

    func onDisappear() {
        currentTask?.cancel()
        watchlistTask?.cancel()
        watchlistTask = nil
        posterPrefetchController.stop()
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
        guard !isLoading, hasMoreItems else { return }
        let nextBatchThreshold = max(movies.count - Constants.loadMoreThreshold, Constants.loadMoreThreshold)
        if currentIndex >= nextBatchThreshold {
            loadNextPage()
        }
    }

    func dismissError() {
        error = nil
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int) {
        posterPrefetchController.itemVisibilityChanged(
            index: index,
            isVisible: isVisible,
            columns: columns,
            itemCount: items.count,
            posterURLAt: { [weak self] index in
                self?.items[safe: index]?.posterURL
            }
        )
    }

    func itemsCountChanged(columns: Int) {
        posterPrefetchController.itemCountChanged(
            columns: columns,
            itemCount: items.count,
            posterURLAt: { [weak self] index in
                self?.items[safe: index]?.posterURL
            }
        )
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
        guard !isLoading else { return }
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
        guard !isLoading else { return }
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
        isLoading = true
        isInitialLoading = isInitial
        isLoadingMore = !isInitial
        error = nil
    }

    private func clearLoadingState() {
        isLoading = false
        isInitialLoading = false
        isLoadingMore = false
    }

    private func setError(_ error: Error) {
        self.error = MovieCatalogErrorState(
            message: error.localizedDescription,
            retry: { [weak self] in
                self?.loadNextPage()
            }
        )
    }

    private func updateItemsAndTitle(previousCount: Int? = nil) {
        if let previousCount, canAppendItems(from: previousCount) {
            appendItems(from: previousCount)
        } else {
            let loaded = LoadedMovieList(movies: movies, watchlistIds: watchlistIds)
            items = mapper.makeMovies(from: loaded)
        }
        title = Constants.title(for: kind, count: items.count)
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
        guard items.count == movies.count else {
            updateItemsAndTitle()
            return
        }

        var updatedItems = items
        for id in changedIDs {
            guard let index = movieIndexByID[id], let movie = movies[safe: index] else { continue }
            updatedItems[index] = mapper.makeMovie(movie: movie, isInWatchlist: updatedIDs.contains(id))
        }
        items = updatedItems
    }

    private static func makeMovieIndexMap(from movies: [Movie]) -> [Int: Int] {
        Dictionary(uniqueKeysWithValues: movies.enumerated().map { ($1.id, $0) })
    }

    private func canAppendItems(from previousCount: Int) -> Bool {
        guard previousCount >= 0, previousCount <= movies.count else { return false }
        guard items.count == previousCount else { return false }
        guard previousCount > 0 else { return true }
        for index in 0..<previousCount where items[index].id != String(movies[index].id) {
            return false
        }
        return true
    }

    private func appendItems(from previousCount: Int) {
        guard previousCount < movies.count else { return }
        let appended = movies[previousCount...].map { movie in
            mapper.makeMovie(movie: movie, isInWatchlist: watchlistIds.contains(movie.id))
        }
        items.append(contentsOf: appended)
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
