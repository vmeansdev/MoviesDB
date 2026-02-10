import UIKit

public enum UserInterfaceStyle: String {
    case both
    case light
    case dark

    var uiUserInterfaceStyles: [UIUserInterfaceStyle] {
        switch self {
        case .light:
            return [.light]
        case .dark:
            return [.dark]
        case .both:
            return [.light, .dark]
        }
    }
}

extension UIUserInterfaceStyle {
    var name: String {
        switch self {
        case .dark:
            return "dark"
        case .light:
            return "light"
        case .unspecified:
            return "unspecified"
        @unknown default:
            return "unknown"
        }
    }
}
