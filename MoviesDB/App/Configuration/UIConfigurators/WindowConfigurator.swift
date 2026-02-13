import UIKit

@MainActor
protocol WindowConfiguratorProtocol {
    func configure(window: UIWindow?, rootViewController: UIViewController)
}

@MainActor
struct WindowConfigurator: WindowConfiguratorProtocol {
    func configure(window: UIWindow?, rootViewController: UIViewController) {
        window?.backgroundColor = .systemBackground
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}
