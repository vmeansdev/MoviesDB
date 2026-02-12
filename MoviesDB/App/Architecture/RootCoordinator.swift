import MovieDBUI
import UIKit

final class RootCoordinator: @MainActor Coordinator {
    private let window: UIWindow?
    private let windowConfigurator: WindowConfiguratorProtocol
    private let appearanceConfigurator: AppAppearanceConfiguratorProtocol
    private let tabBarController: RootTabBarController
    private let tabBarNavigationManager: TabBarNavigationManager
    private let tabItems: [TabItemConfig]

    init(
        window: UIWindow?,
        windowConfigurator: WindowConfiguratorProtocol,
        appearanceConfigurator: AppAppearanceConfiguratorProtocol,
        tabBarController: RootTabBarController,
        tabBarNavigationManager: TabBarNavigationManager,
        tabItems: [TabItemConfig]
    ) {
        self.window = window
        self.windowConfigurator = windowConfigurator
        self.appearanceConfigurator = appearanceConfigurator
        self.tabBarController = tabBarController
        self.tabBarNavigationManager = tabBarNavigationManager
        self.tabItems = tabItems
    }

    func start() {
        appearanceConfigurator.configure()
        tabBarNavigationManager.configTabs(tabItems: tabItems, selected: nil)
        windowConfigurator.configure(window: window, rootViewController: tabBarController)
    }
}
