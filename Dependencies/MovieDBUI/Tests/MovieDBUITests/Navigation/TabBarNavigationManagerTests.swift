@testable import MovieDBUI
import Testing
import UIKit

struct TabBarNavigationManagerTests {
    @Test
    @MainActor
    func test_init_setsTabBarDelegate() async {
        let tabBarController = UITabBarController()
        let manager = TabBarNavigationManager(tabBarController: tabBarController)

        #expect(tabBarController.delegate === manager)
    }

    @Test
    @MainActor
    func test_configTabs_startsFirstCoordinatorOnly() async {
        let environment = Environment()

        environment.manager.configTabs(tabItems: environment.tabItems, selected: nil)

        #expect(environment.firstCoordinator.startCallCount == 1)
        #expect(environment.secondCoordinator.startCallCount == 0)
    }

    @Test
    @MainActor
    func test_configTabs_withSelected_startsSelectedCoordinatorOnly() async {
        let environment = Environment()

        environment.manager.configTabs(tabItems: environment.tabItems, selected: environment.tabItems[1])

        #expect(environment.firstCoordinator.startCallCount == 0)
        #expect(environment.secondCoordinator.startCallCount == 1)
    }

    @Test
    @MainActor
    func test_tabSelection_startsCoordinatorOnFirstSelect() async {
        let environment = Environment()
        environment.manager.configTabs(tabItems: environment.tabItems, selected: nil)

        _ = environment.manager.tabBarController(environment.tabBarController, shouldSelect: environment.secondViewController)

        #expect(environment.firstCoordinator.startCallCount == 1)
        #expect(environment.secondCoordinator.startCallCount == 1)
    }

    @Test
    @MainActor
    func test_tabSelection_doesNotStartCoordinatorTwice() async {
        let environment = Environment()
        environment.manager.configTabs(tabItems: environment.tabItems, selected: nil)

        _ = environment.manager.tabBarController(environment.tabBarController, shouldSelect: environment.secondViewController)
        _ = environment.manager.tabBarController(environment.tabBarController, shouldSelect: environment.secondViewController)

        #expect(environment.secondCoordinator.startCallCount == 1)
    }
}

@MainActor
private final class MockCoordinator: TabCoordinator {
    private(set) var startCallCount = 0

    func start() {
        startCallCount += 1
    }
}

@MainActor
private final class Environment {
    let tabBarController = UITabBarController()
    lazy var manager = TabBarNavigationManager(tabBarController: tabBarController)

    let firstViewController = UIViewController()
    let secondViewController = UIViewController()

    let firstCoordinator = MockCoordinator()
    let secondCoordinator = MockCoordinator()

    lazy var tabItems: [TabItemConfig] = [
        TabItemConfig(id: "first", viewController: firstViewController, coordinator: firstCoordinator),
        TabItemConfig(id: "second", viewController: secondViewController, coordinator: secondCoordinator)
    ]
}
