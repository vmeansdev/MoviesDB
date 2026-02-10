import SnapshotTesting
import UIKit

public func assertSnapshot<Value: UIView>(
    of value: Value,
    size: CGSize = .zero,
    interfaceStyle: UserInterfaceStyle = .both,
    preferredContentSizeCategory: UIContentSizeCategory = .medium,
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
        window.overrideUserInterfaceStyle = style
        viewController.view.backgroundColor = .systemBackground
        window.backgroundColor = .systemBackground

        let traitCollection = UITraitCollection(preferredContentSizeCategory: preferredContentSizeCategory)
        viewController.setOverrideTraitCollection(traitCollection, forChild: viewController)

        value.setNeedsLayout()
        value.layoutIfNeeded()
        viewController.view.layoutIfNeeded()
        assertSnapshot(
            of: window,
            as: .image,
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
