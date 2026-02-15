import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import MovieDBUI

@MainActor
struct MovieCatalogItemViewTests {
    @Test
    func test_movieCatalogItemView_snapshot() {
        let posterURL = Bundle.module.url(forResource: "pup", withExtension: "jpg")
        let view = MovieCatalogItemView(
            model: MovieCollectionViewModel(
                id: "movie-1",
                title: "The Wrecking Crew",
                subtitle: "2026-01-28",
                posterURL: posterURL,
                watchlistIcon: MovieDBUIAssets.system.heartIcon,
                watchlistSelectedIcon: nil,
                watchlistTintColor: .systemPink,
                isInWatchlist: true
            ),
            height: Constants.height,
            posterRenderSize: Constants.renderSize,
            onToggleWatchlist: {}
        )

        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: Constants.size)

        assertSnapshot(
            of: hostingController.view,
            size: Constants.size,
            interfaceStyle: .both,
            preferredContentSizeCategory: .medium
        )
    }
}

private enum Constants {
    static let width: CGFloat = 390
    static let height: CGFloat = 250
    static let size = CGSize(width: width, height: height)
    static let renderSize = CGSize(width: width, height: height)
}
