import SwiftUI

public struct LoadingStateView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: Constants.stackSpacing) {
            ProgressView()
                .progressViewStyle(.circular)
            Text(MovieDBUILocalizable.string(.loadingAccessibilityLabel))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(Constants.backgroundOpacity))
        .accessibilityElement(children: .combine)
    }
}

private enum Constants {
    static let stackSpacing: CGFloat = 12
    static let backgroundOpacity: CGFloat = 0.9
}
