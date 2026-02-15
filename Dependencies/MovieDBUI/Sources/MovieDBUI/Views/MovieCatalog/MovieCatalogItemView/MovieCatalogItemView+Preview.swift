import SwiftUI

#Preview {
    MovieCatalogItemView(
        model: MovieCollectionViewModel(
            id: "preview",
            title: "Preview Movie",
            subtitle: "2026-01-07",
            posterURL: nil,
            watchlistIcon: MovieDBUIAssets.system.heartIcon,
            watchlistSelectedIcon: nil,
            watchlistTintColor: .systemPink,
            isInWatchlist: true
        ),
        height: 250,
        onToggleWatchlist: {}
    )
    .padding()
}
