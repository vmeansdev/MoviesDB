import MovieDBData
import MovieDBUI
import SwiftUI

#Preview {
    WatchlistView(
        viewModel: WatchlistViewModel(
            watchlistStore: PreviewWatchlistStore(),
            uiAssets: MovieDBUIAssets.system,
            prefetchCommandGate: PrefetchCommandGate(
                controller: PosterPrefetchController(posterImagePrefetcher: PosterImagePrefetcher.shared)
            )
        ),
        posterRenderSizeProvider: PosterRenderSizeProvider(),
        viewModelProvider: PreviewViewModelProvider()
    )
}

@MainActor
private final class PreviewViewModelProvider: ViewModelProviderProtocol {
    func makeMovieCatalogViewModel(kind: MovieCatalogViewModel.Kind) -> MovieCatalogViewModel {
        fatalError("Not used in WatchlistView preview")
    }

    func makeWatchlistViewModel() -> WatchlistViewModel {
        fatalError("Not used in WatchlistView preview")
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

private actor PreviewWatchlistStore: WatchlistStoreProtocol {
    private let itemsList: [Movie] = [
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
        )
    ]

    func items() async -> [Movie] { itemsList }

    func itemsStream() async -> AsyncStream<[Movie]> {
        AsyncStream { continuation in
            continuation.yield(itemsList)
            continuation.finish()
        }
    }

    func isInWatchlist(id: Int) async -> Bool {
        itemsList.contains { $0.id == id }
    }

    func add(movie: Movie) async {}
    func remove(id: Int) async {}
    func toggle(movie: Movie) async {}
}
