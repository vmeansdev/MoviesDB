import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import MovieDBUI

@MainActor
struct LoadingStateViewTests {
    @Test
    func test_loadingStateView_snapshot() {
        let view = LoadingStateView()
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
    static let size = CGSize(width: 390, height: 844)
}
