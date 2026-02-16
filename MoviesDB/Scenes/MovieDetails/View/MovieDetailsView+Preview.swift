import MovieDBData
import MovieDBUI
import SwiftUI

#Preview {
    let movie = Movie(
        adult: false,
        backdropPath: nil,
        genreIDS: [18],
        id: 1,
        originalLanguage: "en",
        originalTitle: "Preview Original",
        overview: "A sample overview for previewing movie details.",
        popularity: 1,
        posterPath: nil,
        releaseDate: "2026-01-07",
        title: "Preview Movie",
        video: false,
        voteAverage: 7.4,
        voteCount: 120
    )

    MovieDetailsView(
        viewModel: MovieDetailsViewModel(
            movie: movie,
            moviesService: nil,
            watchlistStore: nil,
            uiAssets: MovieDBUIAssets.system
        )
    )
}
