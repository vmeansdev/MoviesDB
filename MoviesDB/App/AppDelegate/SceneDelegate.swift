import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()

        let dependenciesProvider = DependenciesProvider(
            window: window,
            rootNavigationController: navigationController,
            windowConfigurator: WindowConfigurator(),
            navigationControllerConfigurator: NavigationControllerConfigurator()
        )

        dependenciesProvider.coordinatorProvider.rootCoordinator().start()
        self.window = window
    }
}
