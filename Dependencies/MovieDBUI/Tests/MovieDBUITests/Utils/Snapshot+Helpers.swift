import SnapshotTesting
import UIKit

@MainActor
public func assertSnapshot<Value: UIView>(
    of value: Value,
    size: CGSize = .zero,
    interfaceStyle: UserInterfaceStyle = .both,
    preferredContentSizeCategory: UIContentSizeCategory = .medium,
    wait: TimeInterval = 0,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    let shouldRecord = recording || ProcessInfo.processInfo.environment["SNAPSHOT_TESTING_RECORD"] == "1"
    let frame = CGRect(origin: .zero, size: size)
    let viewController = UIViewController()
    viewController.view = UIView(frame: frame)
    viewController.view.addSubview(value)
    defer { viewController.view = nil }

    let window = UIWindow(frame:  frame)
    window.rootViewController = viewController
    window.makeKeyAndVisible()

    for style in interfaceStyle.uiUserInterfaceStyles {
        viewController.view.backgroundColor = .systemBackground
        viewController.traitOverrides.preferredContentSizeCategory = preferredContentSizeCategory
        window.backgroundColor = .systemBackground
        window.overrideUserInterfaceStyle = style
        value.setNeedsLayout()
        value.layoutIfNeeded()
        viewController.view.layoutIfNeeded()

        let strategy: Snapshotting<UIView, UIImage> = wait > 0
            ? .wait(for: wait, on: .image)
            : .image

        assertSnapshot(
            of: window as UIView,
            as: strategy,
            named: [preferredContentSizeCategory.rawValue, style.name].joined(separator: "_"),
            record: shouldRecord,
            timeout: timeout,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}
