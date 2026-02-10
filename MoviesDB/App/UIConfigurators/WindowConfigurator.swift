import UIKit

@MainActor
protocol WindowConfiguratorProtocol {
    func configure(window: UIWindow?, navigationController: UINavigationController)
}

struct WindowConfigurator: WindowConfiguratorProtocol {
    func configure(window: UIWindow?, navigationController: UINavigationController) {
        window?.backgroundColor = .systemBackground
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
