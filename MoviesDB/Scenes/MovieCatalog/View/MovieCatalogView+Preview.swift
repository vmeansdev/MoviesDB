import MovieDBData
import MovieDBUI
import Observation
import SwiftUI

#Preview {
    let provider = PreviewViewModelProvider()
    MovieCatalogView(
        viewModel: PreviewMovieCatalogViewModel(),
        posterRenderSizeProvider: PosterRenderSizeProvider(),
        viewModelProvider: provider
    )
}

@MainActor
@Observable
private final class PreviewMovieCatalogViewModel: MovieCatalogViewModelProtocol {
    var title: String { "Popular \(state.items.count)" }
    var state: MovieCatalogViewModelState

    private let movies: [Movie]

    init() {
        movies = [
            Movie(
                adult: false,
                backdropPath: nil,
                genreIDS: [],
                id: 1,
                originalLanguage: "en",
                originalTitle: "Preview One",
                overview: "Preview",
                popularity: 0,
                posterPath: "",
                releaseDate: "2026-01-07",
                title: "Preview One",
                video: false,
                voteAverage: 7.4,
                voteCount: 120
            ),
            Movie(
                adult: false,
                backdropPath: nil,
                genreIDS: [],
                id: 2,
                originalLanguage: "en",
                originalTitle: "Preview Two",
                overview: "Preview",
                popularity: 0,
                posterPath: "",
                releaseDate: "2025-12-18",
                title: "Preview Two",
                video: false,
                voteAverage: 7.1,
                voteCount: 98
            )
        ]

        state = MovieCatalogViewModelState(items: [
            MovieCollectionViewModel(
                id: "1",
                title: "Preview One",
                subtitle: "2026-01-07",
                posterURL: nil,
                watchlistIcon: MovieDBUIAssets.system.heartIcon,
                watchlistSelectedIcon: nil,
                watchlistTintColor: .systemPink,
                isInWatchlist: false
            ),
            MovieCollectionViewModel(
                id: "2",
                title: "Preview Two",
                subtitle: "2025-12-18",
                posterURL: nil,
                watchlistIcon: MovieDBUIAssets.system.heartIcon,
                watchlistSelectedIcon: nil,
                watchlistTintColor: .systemPink,
                isInWatchlist: true
            )
        ])
    }

    func onAppear() {}
    func onDisappear() {}
    func movie(at index: Int) -> Movie? { movies[safe: index] }
    func toggleWatchlist(at index: Int) {}
    func loadMoreIfNeeded(currentIndex: Int) {}
    func dismissError() { state.phase = .idle }
    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int) {}
    func updateVisibleColumns(_ columns: Int) {}
}

@MainActor
private final class PreviewViewModelProvider: ViewModelProviderProtocol {
    func makeMovieCatalogViewModel(kind: MovieCatalogViewModel.Kind) -> MovieCatalogViewModel {
        fatalError("Not used in MovieCatalogView preview")
    }

    func makeWatchlistViewModel() -> WatchlistViewModel {
        fatalError("Not used in MovieCatalogView preview")
    }

    func makeMovieDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movie: movie,
            moviesService: nil,
            watchlistStore: nil,
            uiAssets: nil
        )
    }
}
