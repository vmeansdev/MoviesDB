import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import MovieDBUI

@MainActor
struct RoundButtonViewTests {
    @Test
    func test_roundButtonView_snapshot() {
        let view = RoundButtonView(
            icon: UIImage(systemName: "heart.fill"),
            tintColor: .systemPink,
            action: { }
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: Constants.snapshotSize)

        assertSnapshot(
            of: hostingController.view,
            size: Constants.snapshotSize,
            interfaceStyle: .both,
            preferredContentSizeCategory: .medium,
            wait: 0.1
        )
    }
}

private enum Constants {
    static let snapshotSize = CGSize(width: 60, height: 60)
}
