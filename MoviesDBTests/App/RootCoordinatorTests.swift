import MovieDBUI
import UIKit
import Testing
@testable import MoviesDB

struct RootCoordinatorTests {
    @Test
    @MainActor
    func test_start_shouldSetTabBarAsRoot() async {
        let window = UIWindow()
        let tabBarController = RootTabBarController(viewControllers: [])
        let tabBarNavigationManager = TabBarNavigationManager(tabBarController: tabBarController)
        let popular = MockCoordinator()
        let topRated = MockCoordinator()
        let tabItems = [
            TabItemConfig(id: "popular", viewController: UIViewController(), coordinator: popular),
            TabItemConfig(id: "topRated", viewController: UIViewController(), coordinator: topRated)
        ]
        let sut = RootCoordinator(
            window: window,
            windowConfigurator: WindowConfigurator(),
            appearanceConfigurator: AppAppearanceConfigurator.self,
            tabBarController: tabBarController,
            tabBarNavigationManager: tabBarNavigationManager,
            tabItems: tabItems
        )

        sut.start()

        #expect(window.rootViewController is RootTabBarController)
        #expect(popular.startCallCount == 1)
        #expect(topRated.startCallCount == 0)
    }
}
