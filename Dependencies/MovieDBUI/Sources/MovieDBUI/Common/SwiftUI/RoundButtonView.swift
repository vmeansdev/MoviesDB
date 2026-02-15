import SwiftUI
import UIKit

public struct RoundButtonView: View {
    private let icon: UIImage?
    private let tintColor: UIColor
    private let action: () -> Void

    public init(icon: UIImage?, tintColor: UIColor, action: @escaping () -> Void) {
        self.icon = icon
        self.tintColor = tintColor
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(uiImage: icon ?? UIImage())
                .renderingMode(.template)
                .foregroundColor(Color(tintColor))
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .padding(Constants.iconPadding)
                .background(Color.white.opacity(Constants.backgroundOpacity))
                .clipShape(Circle())
        }
    }
}

private enum Constants {
    static let iconSize: CGFloat = 20
    static let iconPadding: CGFloat = 8
    static let backgroundOpacity: CGFloat = 0.5
}
