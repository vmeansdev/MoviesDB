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
                .frame(width: 20, height: 20)
                .padding(8)
                .background(Color.black.opacity(0.35))
                .clipShape(Circle())
        }
    }
}
