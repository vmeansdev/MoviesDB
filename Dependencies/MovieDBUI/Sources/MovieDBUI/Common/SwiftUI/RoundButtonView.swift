import SwiftUI
import UIKit

public struct RoundButtonView: View {
    private let icon: UIImage?
    private let tintColor: UIColor
    private let action: () -> Void
    @State private var isPulsing = false

    public init(icon: UIImage?, tintColor: UIColor, action: @escaping () -> Void) {
        self.icon = icon
        self.tintColor = tintColor
        self.action = action
    }

    public var body: some View {
        Button {
            triggerPulse()
            action()
        } label: {
            Image(uiImage: icon ?? UIImage())
                .renderingMode(.template)
                .foregroundColor(Color(tintColor))
                .frame(width: Constants.iconSide, height: Constants.iconSide)
                .padding(Constants.padding)
                .background(Color.white.opacity(Constants.backgroundOpacity))
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .fill(Color.white.opacity(Constants.backgroundOpacity))
                        .scaleEffect(isPulsing ? Constants.pulseScaleTo : Constants.pulseScaleFrom)
                        .opacity(isPulsing ? Constants.pulseOpacityTo : Constants.pulseOpacityFrom)
                }
        }
        .buttonStyle(.borderless)
    }

    private func triggerPulse() {
        isPulsing = false
        withAnimation(.easeOut(duration: Constants.pulseDuration)) {
            isPulsing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.pulseDuration) {
            isPulsing = false
        }
    }
}

private enum Constants {
    static let iconSide: CGFloat = 20
    static let padding: CGFloat = 8
    static let backgroundOpacity: CGFloat = 0.5
    static let pulseScaleFrom: CGFloat = 1.0
    static let pulseScaleTo: CGFloat = 1.6
    static let pulseOpacityFrom: CGFloat = 0.45
    static let pulseOpacityTo: CGFloat = 0.0
    static let pulseDuration: TimeInterval = 0.45
}
