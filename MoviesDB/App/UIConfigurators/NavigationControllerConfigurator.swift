import UIKit

@MainActor
protocol NavigationControllerConfiguratorProtocol {
    func configure(navigationController: UINavigationController)
}

struct NavigationControllerConfigurator: NavigationControllerConfiguratorProtocol {
    func configure(navigationController: UINavigationController) {
        navigationController.navigationBar.prefersLargeTitles = true
    }
}
