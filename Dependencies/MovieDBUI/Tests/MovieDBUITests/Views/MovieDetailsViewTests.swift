import SnapshotTesting
import SwiftUI
import Testing
import UIKit
import Kingfisher
@testable import MovieDBUI

@MainActor
struct MovieDetailsViewTests {
    @Test
    func test_movieDetailsView_snapshot() {
        let environment = Environment()
        environment.preloadImages()
        let view = environment.makeView()
        environment.contentSizes.forEach { contentSize in
            let hostingController = UIHostingController(rootView: view)
            hostingController.view.frame = CGRect(origin: .zero, size: environment.size)
            assertSnapshot(
                of: hostingController.view,
                size: environment.size,
                interfaceStyle: .both,
                preferredContentSizeCategory: contentSize,
                wait: 0.5
            )
        }
    }
}

@MainActor
private struct Environment {
    let contentSizes: [UIContentSizeCategory] = [.medium, .accessibilityMedium, .accessibilityExtraLarge]
    let size = UIScreen.main.bounds.size

    func makeView() -> MovieDetailsView {
        let pupURL = Bundle.module.url(forResource: "pup", withExtension: "jpg")
        return MovieDetailsView(
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
                    posterURL: pupURL,
                    backdropURL: pupURL
                )
            )
        )
    }

    func preloadImages() {
        guard let pupURL = Bundle.module.url(forResource: "pup", withExtension: "jpg"),
              let data = try? Data(contentsOf: pupURL),
              let image = UIImage(data: data) else { return }
        let resource = ImageResource(downloadURL: pupURL, cacheKey: pupURL.absoluteString)
        ImageCache.default.store(image, forKey: resource.cacheKey)
    }
}
