import UIKit

@MainActor
final class RootCoordinator: Coordinator {
    private let rootViewController: UINavigationController

    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }

    func start() {
        let viewController = ViewController()
        rootViewController.setViewControllers([viewController], animated: false)
    }
}
