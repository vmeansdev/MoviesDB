import Foundation
import MovieDBData
import MovieDBUI

protocol PopularInteractorProtocol: MovieListInteractorProtocol {}

@MainActor
protocol PopularInteractorOutput: AnyObject, Sendable {
    func didSelect(movie: Movie)
}

actor PopularInteractor: PopularInteractorProtocol {
    private let presenter: PopularPresenterProtocol
    private let service: MoviesServiceProtocol
    private let watchlistStore: WatchlistStoreProtocol
    private let output: PopularInteractorOutput
    private let language: String
    private(set) var currentTask: Task<Void, Never>?
    private(set) var watchlistTask: Task<Void, Never>?
    private(set) var popular = LoadedPopular(currentPage: 0, totalPages: 1, totalResults: 0, movies: [], watchlistIds: [])
    private(set) var watchlistIds: Set<Int> = []
    private(set) var isLoading = false

    init(
        presenter: PopularPresenterProtocol,
        service: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        output: PopularInteractorOutput,
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
        guard let movie = popular.movies[safe: item] else {
            return
        }
        await MainActor.run { output.didSelect(movie: movie) }
    }

    func didToggleWatchlist(item: Int) async {
        guard let movie = popular.movies[safe: item] else { return }
        await watchlistStore.toggle(movie: movie)
    }

    func loadMore() async {
        guard !isLoading, await popular.hasMoreItems else { return }
        loadNextPage()
    }

    func canLoadMore(item: Int) async -> Bool {
        let nextBatchThreshold = max(popular.movies.count - Constants.loadMoreThreshold, Constants.loadMoreThreshold)
        let hasMoreItems = await popular.hasMoreItems
        return item >= nextBatchThreshold && hasMoreItems && !isLoading
    }

    private func loadNextPage() {
        currentTask?.cancel()
        currentTask = Task { [weak self] in
            await self?.performLoadNextPage()
        }
    }

    private func performLoadNextPage() async {
        let nextPage = popular.currentPage + 1
        if popular.currentPage == 0 {
            await fetchInitialPages(startingAt: nextPage)
        } else {
            await fetchPopular(page: nextPage)
        }
    }

    private func fetchPopular(page: Int) async {
        guard !isLoading else { return }
        do {
            guard !Task.isCancelled else { return }
            isLoading = true
            await presenter.present(state: .loading(isInitial: popular.currentPage == 0))
            let response = try await fetchPage(page: page)
            let updated = LoadedPopular(
                currentPage: response.page,
                totalPages: response.totalPages,
                totalResults: response.totalResults,
                movies: popular.movies + response.results,
                watchlistIds: watchlistIds
            )
            popular = updated
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

            var movies = popular.movies
            var currentPage = popular.currentPage
            var totalPages = popular.totalPages
            var totalResults = popular.totalResults

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

            let updated = LoadedPopular(
                currentPage: currentPage,
                totalPages: totalPages,
                totalResults: totalResults,
                movies: movies,
                watchlistIds: watchlistIds
            )
            popular = updated
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
        try await service.fetchPopular(options: .init(page: page, language: language))
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
        let updated = LoadedPopular(
            currentPage: popular.currentPage,
            totalPages: popular.totalPages,
            totalResults: popular.totalResults,
            movies: popular.movies,
            watchlistIds: watchlistIds
        )
        popular = updated
        await presenter.present(state: .loaded(updated))
    }
}

nonisolated private enum Constants {
    static let loadMoreThreshold = 5
    static let initialPagesToLoad = 2
    static let en = "en"
}
