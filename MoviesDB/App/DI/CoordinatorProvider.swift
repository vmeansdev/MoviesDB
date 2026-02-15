import MovieDBData
import MovieDBUI
import UIKit

@MainActor
protocol CoordinatorProviderProtocol {
    func rootCoordinator() -> Coordinator
    func popularCoordinator() -> Coordinator
    func topRatedCoordinator() -> Coordinator
    func watchlistCoordinator() -> Coordinator
    func movieDetailsCoordinator(rootViewController: UINavigationController, movie: Movie) -> Coordinator
    func allCoordinators() -> [Coordinator]
}

@MainActor
final class CoordinatorProvider: CoordinatorProviderProtocol {
    private let window: UIWindow?
    private let windowConfigurator: WindowConfiguratorProtocol
    private let appearanceConfigurator: AppAppearanceConfiguratorProtocol
    private let assetsProvider: AssetsProviderProtocol
    private let storeProvider: StoreProviderProtocol
    private let dependenciesProvider: DependenciesProviderProtocol
    private lazy var popularStack: CoordinatorStack = makePopularStack()
    private lazy var topRatedStack: CoordinatorStack = makeTopRatedStack()
    private lazy var watchlistStack: CoordinatorStack = makeWatchlistStack()
    private lazy var root: Coordinator = makeRootCoordinator()

    init(
        window: UIWindow?,
        windowConfigurator: WindowConfiguratorProtocol,
        appearanceConfigurator: AppAppearanceConfiguratorProtocol,
        assetsProvider: AssetsProviderProtocol,
        storeProvider: StoreProviderProtocol,
        dependenciesProvider: DependenciesProviderProtocol
    ) {
        self.window = window
        self.windowConfigurator = windowConfigurator
        self.appearanceConfigurator = appearanceConfigurator
        self.assetsProvider = assetsProvider
        self.storeProvider = storeProvider
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

    func watchlistCoordinator() -> Coordinator {
        watchlistStack.coordinator
    }

    func movieDetailsCoordinator(rootViewController: UINavigationController, movie: Movie) -> Coordinator {
        MovieDetailsCoordinator(
            rootViewController: rootViewController,
            movie: movie,
            dependenciesProvider: dependenciesProvider
        )
    }

    func allCoordinators() -> [Coordinator] {
        [root, popularStack.coordinator, topRatedStack.coordinator, watchlistStack.coordinator]
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
            ),
            TabItemConfig(
                id: TabItemId.watchlist,
                viewController: watchlistStack.navigationController,
                coordinator: watchlistStack.coordinator
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
            image: assetsProvider.uiAssets.popularTabIcon,
            selectedImage: assetsProvider.uiAssets.popularTabSelectedIcon
        )
        let coordinator = MovieCatalogCoordinator(
            kind: .popular,
            rootViewController: navigationController,
            coordinatorProvider: self,
            dependenciesProvider: dependenciesProvider
        )
        return (navigationController, coordinator)
    }

    func makeTopRatedStack() -> CoordinatorStack {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: String.localizable.tabTopRatedTitle,
            image: assetsProvider.uiAssets.topRatedTabIcon,
            selectedImage: assetsProvider.uiAssets.topRatedTabSelectedIcon
        )
        let coordinator = MovieCatalogCoordinator(
            kind: .topRated,
            rootViewController: navigationController,
            coordinatorProvider: self,
            dependenciesProvider: dependenciesProvider
        )
        return (navigationController, coordinator)
    }

    func makeWatchlistStack() -> CoordinatorStack {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: String.localizable.tabWatchlistTitle,
            image: assetsProvider.uiAssets.watchlistTabIcon,
            selectedImage: assetsProvider.uiAssets.watchlistTabSelectedIcon
        )
        let coordinator = WatchlistCoordinator(
            rootViewController: navigationController,
            dependenciesProvider: dependenciesProvider,
            coordinatorProvider: self
        )
        return (navigationController, coordinator)
    }
}
