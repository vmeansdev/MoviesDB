import UIKit

@MainActor
public protocol TabCoordinator: AnyObject {
    func start()
}

public struct TabItemConfig {
    public let id: String
    public let viewController: UIViewController
    public let coordinator: TabCoordinator

    public init(id: String, viewController: UIViewController, coordinator: TabCoordinator) {
        self.id = id
        self.viewController = viewController
        self.coordinator = coordinator
    }
}

@MainActor
public final class TabBarNavigationManager: NSObject, UITabBarControllerDelegate {
    private let tabBarController: UITabBarController
    private var tabItems: [TabItemConfig] = []
    private var startedIds = Set<String>()

    public init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
        super.init()
        tabBarController.delegate = self
    }

    public func configTabs(tabItems: [TabItemConfig], selected: TabItemConfig?) {
        self.tabItems = tabItems
        tabBarController.setViewControllers(tabItems.map(\.viewController), animated: false)

        if let selected, let index = tabItems.firstIndex(where: { $0.id == selected.id }) {
            tabBarController.selectedIndex = index
        } else {
            tabBarController.selectedIndex = 0
        }

        startIfNeeded(for: tabBarController.selectedViewController)
    }

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        startIfNeeded(for: viewController)
        return true
    }

    private func startIfNeeded(for viewController: UIViewController?) {
        guard let viewController else { return }
        guard let tabItem = tabItems.first(where: { $0.viewController === viewController }) else { return }
        guard !startedIds.contains(tabItem.id) else { return }

        startedIds.insert(tabItem.id)
        tabItem.coordinator.start()
    }
}
