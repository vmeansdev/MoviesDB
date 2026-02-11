import Foundation
import MovieDBData
import MovieDBUI

protocol TopRatedInteractorProtocol: Actor {
    func viewDidLoad() async
    func viewWillUnload() async
    func didSelect(item: Int) async
    func loadMore() async
    func canLoadMore(item: Int) async -> Bool
}

@MainActor
protocol TopRatedInteractorOutput: AnyObject {
    func didSelect(movie: Movie)
}

actor TopRatedInteractor: TopRatedInteractorProtocol {
    private let presenter: TopRatedPresenterProtocol
    private let service: MoviesServiceProtocol
    private let output: TopRatedInteractorOutput
    private let language: String
    private(set) var currentTask: Task<Void, Never>?
    private(set) var topRated = LoadedTopRated(currentPage: 0, totalPages: 1, totalResults: 0, movies: [])
    private(set) var isLoading = false

    init(
        presenter: TopRatedPresenterProtocol,
        service: MoviesServiceProtocol,
        output: TopRatedInteractorOutput,
        language: String = Locale.current.language.languageCode?.identifier ?? Constants.en
    ) {
        self.presenter = presenter
        self.service = service
        self.output = output
        self.language = language
    }

    func viewDidLoad() async {
        loadNextPage()
    }

    func viewWillUnload() async {
        currentTask?.cancel()
    }

    func didSelect(item: Int) async {
        guard let movie = await topRated.movies[safe: item] else { return }
        await output.didSelect(movie: movie)
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
                movies: topRated.movies + response.results
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
                movies: movies
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
}

nonisolated private enum Constants {
    static let loadMoreThreshold = 5
    static let initialPagesToLoad = 2
    static let en = "en"
}
