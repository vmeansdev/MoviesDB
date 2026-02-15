import MovieDBData
import MovieDBUI
import Observation
import SwiftUI

#Preview {
    MovieCatalogView(
        viewModel: PreviewMovieCatalogViewModel(),
        posterRenderSizeProvider: PosterRenderSizeProvider(),
        makeDetailsViewModel: { movie in
            MovieDetailsViewModel(movie: movie, isInWatchlist: false)
        }
    )
}

@MainActor
@Observable
private final class PreviewMovieCatalogViewModel: MovieCatalogViewModelProtocol {
    var title: String = "Popular 2"
    var items: [MovieCollectionViewModel]
    var error: MovieCatalogErrorState? = nil
    var isInitialLoading: Bool = false
    var isLoadingMore: Bool = false

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

        items = [
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
        ]
    }

    func onAppear() {}
    func onDisappear() {}
    func movie(at index: Int) -> Movie? { movies[safe: index] }
    func toggleWatchlist(at index: Int) {}
    func loadMoreIfNeeded(currentIndex: Int) {}
    func dismissError() { error = nil }
    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int) {}
    func itemsCountChanged(columns: Int) {}
}
