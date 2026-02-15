import SnapshotTesting
import SwiftUI
import Testing
import UIKit
@testable import MovieDBUI

@MainActor
struct ErrorStateViewTests {
    @Test
    func test_errorStateView_snapshot() {
        let view = ErrorStateView(
            message: "Something went wrong",
            retry: {},
            onClose: {}
        )
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: Constants.size)

        assertSnapshot(
            of: hostingController.view,
            size: Constants.size,
            interfaceStyle: .both,
            preferredContentSizeCategory: .medium,
            precision: Constants.snapshotPrecision,
            perceptualPrecision: Constants.snapshotPerceptualPrecision
        )
    }
}

private enum Constants {
    static let size = CGSize(width: 390, height: 844)
    static let snapshotPrecision: Float = 0.98
    static let snapshotPerceptualPrecision: Float = 0.95
}
