import SwiftUI

#Preview {
    MovieDetailsView(
        viewModel: MovieDetailsViewModel(
            content: MovieDetailsContent(
                title: "The Example Movie",
                subtitle: "2026 • EN",
                overviewTitle: "Overview",
                overview: "A bold, cinematic story about courage, betrayal, and the price of ambition.",
                metadata: [
                    MovieDetailsMetadataItem(id: "rating", title: "Rating", value: "8.4/10"),
                    MovieDetailsMetadataItem(id: "votes", title: "Votes", value: "12,540"),
                    MovieDetailsMetadataItem(id: "originalTitle", title: "Original title", value: "The Example Movie")
                ],
                posterURL: URL(string: "https://image.tmdb.org/t/p/w500/8FHOtUpNIk5ZPEay2N2EY5lrxkv.jpg"),
                backdropURL: URL(string: "https://image.tmdb.org/t/p/w780/8FHOtUpNIk5ZPEay2N2EY5lrxkv.jpg")
            )
        )
    )
}
