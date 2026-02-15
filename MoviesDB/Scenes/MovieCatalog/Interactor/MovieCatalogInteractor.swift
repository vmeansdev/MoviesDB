import CoreGraphics
import Foundation
import MovieDBData
import MovieDBUI

protocol MovieCatalogInteractorOutput: AnyObject, Sendable {
    func didSelect(movie: Movie)
}

actor MovieCatalogInteractor: MovieCatalogInteractorProtocol {
    private let kind: MovieCatalogKind
    private let presenter: MovieCatalogPresenterProtocol
    private let service: MoviesServiceProtocol
    private let watchlistStore: WatchlistStoreProtocol
    private let output: MovieCatalogInteractorOutput
    private let posterPrefetchController: any PosterPrefetchControlling
    private let posterRenderSizeProvider: any PosterRenderSizeProviding
    private let posterURLProvider: any PosterURLProviding
    private let language: String

    private var currentTask: Task<Void, Never>?
    private var watchlistTask: Task<Void, Never>?
    private var loadedState = LoadedMovieCatalog(currentPage: 0, totalPages: 1, totalResults: 0, movies: [], watchlistIds: [])
    private var watchlistIds: Set<Int> = []
    private var isLoading = false
    private var currentRenderSize = CGSize.zero

    init(
        kind: MovieCatalogKind,
        presenter: MovieCatalogPresenterProtocol,
        service: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        output: MovieCatalogInteractorOutput,
        posterPrefetchController: any PosterPrefetchControlling,
        posterRenderSizeProvider: any PosterRenderSizeProviding,
        posterURLProvider: any PosterURLProviding,
        language: String
    ) {
        self.kind = kind
        self.presenter = presenter
        self.service = service
        self.watchlistStore = watchlistStore
        self.output = output
        self.posterPrefetchController = posterPrefetchController
        self.posterRenderSizeProvider = posterRenderSizeProvider
        self.posterURLProvider = posterURLProvider
        self.language = language
    }

    deinit {
        watchlistTask?.cancel()
    }

    func viewDidLoad() async {
        startWatchlistObservationIfNeeded()
        loadNextPage()
    }

    func viewWillUnload() async {
        currentTask?.cancel()
        await MainActor.run {
            posterPrefetchController.stop()
        }
    }

    func didSelect(item: Int) async {
        guard let movie = loadedState.movies[safe: item] else { return }
        await MainActor.run { output.didSelect(movie: movie) }
    }

    func didToggleWatchlist(item: Int) async {
        guard let movie = loadedState.movies[safe: item] else { return }
        await watchlistStore.toggle(movie: movie)
    }

    func loadMore() async {
        guard !isLoading, loadedState.hasMoreItems else { return }
        loadNextPage()
    }

    func canLoadMore(item: Int) async -> Bool {
        let nextBatchThreshold = max(loadedState.movies.count - Constants.loadMoreThreshold, Constants.loadMoreThreshold)
        return item >= nextBatchThreshold && loadedState.hasMoreItems && !isLoading
    }

    func didUpdateLayout(containerSize: CGSize, columns: Int, itemHeight: CGFloat, minimumColumns: Int) async {
        let renderSize = await MainActor.run {
            posterRenderSizeProvider.size(
                for: containerSize,
                columns: columns,
                itemHeight: itemHeight,
                minimumColumns: minimumColumns
            )
        }
        if renderSize != currentRenderSize {
            currentRenderSize = renderSize
            await presenter.present(posterRenderSize: renderSize)
        }
    }

    func didUpdateVisibleItem(index: Int, isVisible: Bool, columns: Int) async {
        let posterURLs = loadedState.movies.map(posterURL(for:))
        let itemCount = loadedState.movies.count
        await MainActor.run {
            posterPrefetchController.itemVisibilityChanged(
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

    func didUpdateItems(columns: Int) async {
        let posterURLs = loadedState.movies.map(posterURL(for:))
        let itemCount = loadedState.movies.count
        await MainActor.run {
            posterPrefetchController.itemCountChanged(
                columns: columns,
                itemCount: itemCount,
                posterURLAt: { index in
                    guard posterURLs.indices.contains(index) else { return nil }
                    return posterURLs[index]
                }
            )
        }
    }

    private func loadNextPage() {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            await self?.performLoadNextPage()
        }
    }

    private func performLoadNextPage() async {
        let nextPage = loadedState.currentPage + 1
        if loadedState.currentPage == 0 {
            await fetchInitialPages(startingAt: nextPage)
        } else {
            await fetchPageAndPresent(page: nextPage)
        }
    }

    private func fetchPageAndPresent(page: Int) async {
        guard !isLoading else { return }
        do {
            guard !Task.isCancelled else { return }
            isLoading = true
            await presenter.present(state: .loading(isInitial: loadedState.currentPage == 0))
            let response = try await kind.fetch(using: service, options: .init(page: page, language: language))
            let updated = LoadedMovieCatalog(
                currentPage: response.page,
                totalPages: response.totalPages,
                totalResults: response.totalResults,
                movies: appendUniqueMovies(existing: loadedState.movies, incoming: response.results),
                watchlistIds: watchlistIds
            )
            loadedState = updated
            await presenter.present(state: .loaded(updated))
            isLoading = false
        } catch {
            isLoading = false
            await presenter.present(state: .error(error, { [weak self] in
                Task { await self?.loadMore() }
            }))
        }
    }

    private func fetchInitialPages(startingAt page: Int) async {
        guard !isLoading else { return }
        do {
            guard !Task.isCancelled else { return }
            isLoading = true
            await presenter.present(state: .loading(isInitial: true))

            var movies = loadedState.movies
            var currentPage = loadedState.currentPage
            var totalPages = loadedState.totalPages
            var totalResults = loadedState.totalResults

            for index in 0 ..< Constants.initialPagesToLoad {
                let targetPage = page + index
                let response = try await kind.fetch(using: service, options: .init(page: targetPage, language: language))
                currentPage = response.page
                totalPages = response.totalPages
                totalResults = response.totalResults
                movies = appendUniqueMovies(existing: movies, incoming: response.results)
                if response.results.isEmpty || currentPage >= totalPages {
                    break
                }
            }

            let updated = LoadedMovieCatalog(
                currentPage: currentPage,
                totalPages: totalPages,
                totalResults: totalResults,
                movies: movies,
                watchlistIds: watchlistIds
            )
            loadedState = updated
            await presenter.present(state: .loaded(updated))
            isLoading = false
        } catch {
            isLoading = false
            await presenter.present(state: .error(error, { [weak self] in
                Task { await self?.loadMore() }
            }))
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
            await updateWatchlist(items: items)
        }
    }

    private func updateWatchlist(items: [Movie]) async {
        watchlistIds = Set(items.map(\.id))
        let updated = LoadedMovieCatalog(
            currentPage: loadedState.currentPage,
            totalPages: loadedState.totalPages,
            totalResults: loadedState.totalResults,
            movies: loadedState.movies,
            watchlistIds: watchlistIds
        )
        loadedState = updated
        await presenter.present(state: .loaded(updated))
    }

    private func appendUniqueMovies(existing: [Movie], incoming: [Movie]) -> [Movie] {
        var merged = existing
        var seen = Set(existing.map(\.id))
        for movie in incoming where seen.insert(movie.id).inserted {
            merged.append(movie)
        }
        return merged
    }

    private func posterURL(for movie: Movie) -> URL? {
        posterURLProvider.makePosterOrBackdropURL(posterPath: movie.posterPath, backdropPath: movie.backdropPath)
    }

    private enum Constants {
        static let loadMoreThreshold = 20
        static let initialPagesToLoad = 2
    }
}
