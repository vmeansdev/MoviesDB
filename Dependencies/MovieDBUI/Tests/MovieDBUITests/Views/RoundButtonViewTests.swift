import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import MovieDBUI

@MainActor
struct RoundButtonViewTests {
    @Test
    func test_roundButtonView_snapshot() {
        let view = ZStack {
            Color(.systemBackground)
            RoundButtonView(icon: MovieDBUIAssets.system.heartFilledIcon, tintColor: .systemPink) {}
        }

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
    static let size = CGSize(width: 120, height: 120)
}
