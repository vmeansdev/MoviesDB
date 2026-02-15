import Kingfisher
import SwiftUI
import UIKit

public struct MovieCatalogItemView: View {
    public let model: MovieCollectionViewModel
    public let height: CGFloat
    public let posterRenderSize: CGSize?
    public let onToggleWatchlist: () -> Void

    public init(
        model: MovieCollectionViewModel,
        height: CGFloat,
        posterRenderSize: CGSize? = nil,
        onToggleWatchlist: @escaping () -> Void
    ) {
        self.model = model
        self.height = height
        self.posterRenderSize = posterRenderSize
        self.onToggleWatchlist = onToggleWatchlist
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .bottomLeading) {
                poster
                Rectangle()
                    .fill(Color.black.opacity(Constants.overlayOpacity))
                VStack(alignment: .leading, spacing: Constants.textStackSpacing) {
                    Text(model.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(Constants.titleLineLimit)
                    if !model.subtitle.isEmpty {
                        Text(model.subtitle)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(Constants.contentPadding)
            }

            if let icon = model.watchlistIcon {
                RoundButtonView(icon: icon, tintColor: model.watchlistTintColor, action: onToggleWatchlist)
                    .contentShape(Circle())
                    .accessibilityLabel(Text(watchlistAccessibilityLabel))
                    .accessibilityValue(Text(watchlistAccessibilityValue))
                    .accessibilityHint(Text(MovieDBUILocalizable.string(.watchlistAccessibilityHint)))
                    .padding(Constants.watchlistButtonPadding)
            }
        }
        .frame(height: height)
        .contentShape(Rectangle())
    }

    private var poster: some View {
        Group {
            if let url = model.posterURL, url.isFileURL, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if model.posterURL != nil {
                KFImage(model.posterURL)
                    .setProcessor(DownsamplingImageProcessor(size: posterDownsamplingSize))
                    .cancelOnDisappear(true)
                    .placeholder { placeholder }
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .accessibilityLabel(Text(MovieDBUILocalizable.format(.posterAccessibilityFormat, model.title)))
        .accessibilityAddTraits(.isImage)
    }

    private var watchlistAccessibilityLabel: String {
        model.isInWatchlist
            ? MovieDBUILocalizable.string(.watchlistAccessibilityRemove)
            : MovieDBUILocalizable.string(.watchlistAccessibilityAdd)
    }

    private var watchlistAccessibilityValue: String {
        model.isInWatchlist
            ? MovieDBUILocalizable.string(.watchlistAccessibilityValueIn)
            : MovieDBUILocalizable.string(.watchlistAccessibilityValueOut)
    }

    private var posterDownsamplingSize: CGSize {
        let baseSize = posterRenderSize ?? CGSize(width: UIScreen.main.bounds.width, height: height)
        let scale = UIScreen.main.scale
        return CGSize(
            width: baseSize.width * scale,
            height: baseSize.height * scale
        )
    }

    private var placeholder: some View {
        Color(.tertiarySystemBackground)
    }
}

private enum Constants {
    static let overlayOpacity: CGFloat = 0.25
    static let textStackSpacing: CGFloat = 4
    static let titleLineLimit = 2
    static let contentPadding: CGFloat = 8
    static let watchlistButtonPadding: CGFloat = 8
}
