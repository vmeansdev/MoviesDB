import Foundation
import MovieDBData
import MovieDBUI

protocol TopRatedInteractorProtocol: MovieListInteractorProtocol {}

@MainActor
protocol TopRatedInteractorOutput: AnyObject {
    func didSelect(movie: Movie)
}

actor TopRatedInteractor: TopRatedInteractorProtocol {
    private let presenter: TopRatedPresenterProtocol
    private let service: MoviesServiceProtocol
    private let watchlistStore: WatchlistStoreProtocol
    private let output: TopRatedInteractorOutput
    private let language: String
    private(set) var currentTask: Task<Void, Never>?
    private(set) var watchlistTask: Task<Void, Never>?
    private(set) var topRated = LoadedTopRated(currentPage: 0, totalPages: 1, totalResults: 0, movies: [], watchlistIds: [])
    private(set) var watchlistIds: Set<Int> = []
    private(set) var isLoading = false

    init(
        presenter: TopRatedPresenterProtocol,
        service: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        output: TopRatedInteractorOutput,
        language: String = Locale.current.language.languageCode?.identifier ?? Constants.en
    ) {
        self.presenter = presenter
        self.service = service
        self.watchlistStore = watchlistStore
        self.output = output
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
    }

    func didSelect(item: Int) async {
        guard let movie = topRated.movies[safe: item] else { return }
        await output.didSelect(movie: movie)
    }

    func didToggleWatchlist(item: Int) async {
        guard let movie = topRated.movies[safe: item] else { return }
        await watchlistStore.toggle(movie: movie)
    }

    func loadMore() async {
        guard !isLoading, await topRated.hasMoreItems else { return }
        loadNextPage()
    }

    func canLoadMore(item: Int) async -> Bool {
        let nextBatchThreshold = max(topRated.movies.count - Constants.loadMoreThreshold, Constants.loadMoreThreshold)
        let hasMoreItems = await topRated.hasMoreItems
        return item >= nextBatchThreshold && hasMoreItems && !isLoading
    }

    private func loadNextPage() {
        currentTask?.cancel()
        currentTask = Task {
            let nextPage = topRated.currentPage + 1
            if topRated.currentPage == 0 {
                await fetchInitialPages(startingAt: nextPage)
            } else {
                await fetchTopRated(page: nextPage)
            }
        }
    }

    private func fetchTopRated(page: Int) async {
        guard !isLoading else { return }
        do {
            guard !Task.isCancelled else { return }
            isLoading = true
            await presenter.present(state: .loading(isInitial: topRated.currentPage == 0))
            let response = try await fetchPage(page: page)
            let updated = LoadedTopRated(
                currentPage: response.page,
                totalPages: response.totalPages,
                totalResults: response.totalResults,
                movies: topRated.movies + response.results,
                watchlistIds: watchlistIds
            )
            topRated = updated
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

            var movies = topRated.movies
            var currentPage = topRated.currentPage
            var totalPages = topRated.totalPages
            var totalResults = topRated.totalResults

            for index in 0..<Constants.initialPagesToLoad {
                let targetPage = page + index
                let response = try await fetchPage(page: targetPage)
                currentPage = response.page
                totalPages = response.totalPages
                totalResults = response.totalResults
                movies.append(contentsOf: response.results)
                if response.results.isEmpty || currentPage >= totalPages {
                    break
                }
            }

            let updated = LoadedTopRated(
                currentPage: currentPage,
                totalPages: totalPages,
                totalResults: totalResults,
                movies: movies,
                watchlistIds: watchlistIds
            )
            topRated = updated
            await presenter.present(state: .loaded(updated))
            isLoading = false
        } catch {
            isLoading = false
            await presenter.present(state: .error(error, { [weak self] in
                Task { await self?.loadMore() }
            }))
        }
    }

    private func fetchPage(page: Int) async throws -> MovieList {
        try await service.fetchTopRated(options: .init(page: page, language: language))
    }

    private func startWatchlistObservationIfNeeded() {
        guard watchlistTask == nil else { return }
        watchlistTask = Task {
            let stream = await watchlistStore.itemsStream()
            for await items in stream {
                await updateWatchlist(items: items)
            }
        }
    }

    private func updateWatchlist(items: [Movie]) async {
        watchlistIds = Set(items.map(\.id))
        let updated = LoadedTopRated(
            currentPage: topRated.currentPage,
            totalPages: topRated.totalPages,
            totalResults: topRated.totalResults,
            movies: topRated.movies,
            watchlistIds: watchlistIds
        )
        topRated = updated
        await presenter.present(state: .loaded(updated))
    }
}

nonisolated private enum Constants {
    static let loadMoreThreshold = 5
    static let initialPagesToLoad = 2
    static let en = "en"
}
