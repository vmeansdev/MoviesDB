import MovieDBData
import MovieDBUI
import UIKit

@MainActor
protocol CoordinatorProviderProtocol {
    func rootCoordinator() -> Coordinator
    func popularCoordinator() -> Coordinator
    func topRatedCoordinator() -> Coordinator
    func movieDetailsCoordinator(rootViewController: UINavigationController, movie: Movie) -> Coordinator
    func allCoordinators() -> [Coordinator]
}

final class CoordinatorProvider: CoordinatorProviderProtocol {
    private let window: UIWindow?
    private let serviceProvider: ServiceProviderProtocol
    private let windowConfigurator: WindowConfiguratorProtocol
    private let appearanceConfigurator: AppAppearanceConfiguratorProtocol
    private let uiAssets: MovieDBUIAssetsProtocol
    private let dependenciesProvider: DependenciesProviderProtocol
    private lazy var popularStack: CoordinatorStack = makePopularStack()
    private lazy var topRatedStack: CoordinatorStack = makeTopRatedStack()
    private lazy var root: Coordinator = makeRootCoordinator()

    init(
        window: UIWindow?,
        serviceProvider: ServiceProviderProtocol,
        windowConfigurator: WindowConfiguratorProtocol,
        appearanceConfigurator: AppAppearanceConfiguratorProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        dependenciesProvider: DependenciesProviderProtocol
    ) {
        self.window = window
        self.serviceProvider = serviceProvider
        self.windowConfigurator = windowConfigurator
        self.appearanceConfigurator = appearanceConfigurator
        self.uiAssets = uiAssets
        self.dependenciesProvider = dependenciesProvider
    }

    func rootCoordinator() -> Coordinator {
        root
    }

    func popularCoordinator() -> Coordinator {
        popularStack.coordinator
    }

    func topRatedCoordinator() -> Coordinator {
        topRatedStack.coordinator
    }

    func movieDetailsCoordinator(rootViewController: UINavigationController, movie: Movie) -> Coordinator {
        MovieDetailsCoordinator(
            rootViewController: rootViewController,
            movie: movie,
            dependenciesProvider: dependenciesProvider
        )
    }

    func allCoordinators() -> [Coordinator] {
        [root, popularStack.coordinator, topRatedStack.coordinator]
    }
}

private extension CoordinatorProvider {
    typealias CoordinatorStack = (navigationController: UINavigationController, coordinator: Coordinator)

    func makeRootCoordinator() -> Coordinator {
        let tabBarController = RootTabBarController(viewControllers: [])
        let tabBarNavigationManager = TabBarNavigationManager(tabBarController: tabBarController)
        let tabItems = [
            TabItemConfig(
                id: TabItemId.popular,
                viewController: popularStack.navigationController,
                coordinator: popularStack.coordinator
            ),
            TabItemConfig(
                id: TabItemId.topRated,
                viewController: topRatedStack.navigationController,
                coordinator: topRatedStack.coordinator
            )
        ]

        return RootCoordinator(
            window: window,
            windowConfigurator: windowConfigurator,
            appearanceConfigurator: appearanceConfigurator,
            tabBarController: tabBarController,
            tabBarNavigationManager: tabBarNavigationManager,
            tabItems: tabItems
        )
    }

    func makePopularStack() -> CoordinatorStack {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: String.localizable.tabPopularTitle,
            image: uiAssets.popularTabIcon,
            selectedImage: uiAssets.popularTabSelectedIcon
        )
        let coordinator = PopularCoordinator(
            rootViewController: navigationController,
            serviceProvider: serviceProvider,
            coordinatorProvider: self
        )
        return (navigationController, coordinator)
    }

    func makeTopRatedStack() -> CoordinatorStack {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: String.localizable.tabTopRatedTitle,
            image: uiAssets.topRatedTabIcon,
            selectedImage: uiAssets.topRatedTabSelectedIcon
        )
        let coordinator = TopRatedCoordinator(
            rootViewController: navigationController,
            serviceProvider: serviceProvider,
            coordinatorProvider: self
        )
        return (navigationController, coordinator)
    }
}
