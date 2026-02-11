import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import MovieDBUI

struct MovieDetailsViewTests {
    @Test
    @MainActor
    func test_movieDetailsView_snapshot() async {
        let environment = Environment()
        environment.contentSizes.forEach { contentSize in
            let hostingController = UIHostingController(rootView: environment.view)
            hostingController.view.frame = CGRect(origin: .zero, size: environment.size)
            assertSnapshot(
                of: hostingController.view,
                size: environment.size,
                interfaceStyle: .both,
                preferredContentSizeCategory: contentSize
            )
        }
    }
}

private struct Environment {
    let contentSizes: [UIContentSizeCategory] = [.medium, .accessibilityMedium, .accessibilityExtraLarge]
    let size = UIScreen.main.bounds.size
    let view = MovieDetailsView(
        viewModel: MovieDetailsViewModel(
            content: MovieDetailsContent(
                title: "The Wrecking Crew",
                subtitle: nil,
                overviewTitle: "Overview",
                overview: "Estranged half-brothers Jonny and James reunite after their father's mysterious death.",
                metadata: [
                    MovieDetailsMetadataItem(id: "rating", title: "Rating", value: "6.8/10"),
                    MovieDetailsMetadataItem(id: "votes", title: "Votes", value: "505"),
                    MovieDetailsMetadataItem(id: "releaseDate", title: "Release date", value: "2026-01-28"),
                    MovieDetailsMetadataItem(id: "language", title: "Language", value: "EN")
                ],
                posterURL: URL(string: "https://image.tmdb.org/t/p/w500/8FHOtUpNIk5ZPEay2N2EY5lrxkv.jpg"),
                backdropURL: URL(string: "https://image.tmdb.org/t/p/w780/8FHOtUpNIk5ZPEay2N2EY5lrxkv.jpg")
            )
        )
    )
}
