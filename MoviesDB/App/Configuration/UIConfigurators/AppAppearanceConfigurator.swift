import UIKit

protocol AppAppearanceConfiguratorProtocol {
    func configure()
}

struct AppAppearanceConfigurator: AppAppearanceConfiguratorProtocol {
    func configure() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithDefaultBackground()
        navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = navigationAppearance
        navBar.scrollEdgeAppearance = navigationAppearance
        navBar.compactAppearance = navigationAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)

        let tabBar = UITabBar.appearance()
        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        tabBar.isTranslucent = true
    }
}
