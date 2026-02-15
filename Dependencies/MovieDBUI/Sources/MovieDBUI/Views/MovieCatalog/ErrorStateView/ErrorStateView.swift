import SwiftUI

public struct ErrorStateView: View {
    public let message: String
    public let retry: (() -> Void)?
    public let onClose: () -> Void

    public init(message: String, retry: (() -> Void)?, onClose: @escaping () -> Void) {
        self.message = message
        self.retry = retry
        self.onClose = onClose
    }

    public var body: some View {
        VStack(spacing: Constants.stackSpacing) {
            Text(message)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            if let retry {
                Button(MovieDBUILocalizable.string(.errorRetryTitle)) {
                    retry()
                }
                .buttonStyle(.borderedProminent)
            }

            Button(MovieDBUILocalizable.string(.errorCloseTitle)) {
                onClose()
            }
            .buttonStyle(.bordered)
        }
        .padding(Constants.contentPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .contain)
    }
}

private enum Constants {
    static let stackSpacing: CGFloat = 16
    static let contentPadding: CGFloat = 24
}
