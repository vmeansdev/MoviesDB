import Foundation
import Kingfisher
import MovieDBUI
import SwiftUI

struct WatchlistRow: View {
    @SwiftUI.Environment(\.displayScale) private var displayScale

    let title: String
    let releaseDate: String?
    let posterURL: URL?
    let heartIcon: UIImage?
    let heartFilledIcon: UIImage?
    let tintColor: UIColor
    let onSelect: () -> Void
    let onToggle: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .bottomLeading) {
                poster
                Rectangle()
                    .fill(Color.black.opacity(Constants.overlayOpacity))
                VStack(alignment: .leading, spacing: Constants.titleStackSpacing) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(Constants.titleLineLimit)
                    if let releaseDate, !releaseDate.isEmpty {
                        Text(releaseDate)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(Constants.contentPadding)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            RoundButtonView(icon: heartFilledIcon, tintColor: tintColor, action: onToggle)
                .padding(Constants.contentPadding)
                .contentShape(Circle())
                .highPriorityGesture(TapGesture().onEnded(onToggle))
                .accessibilityLabel(Text(watchlistAccessibilityLabel))
                .accessibilityValue(Text(watchlistAccessibilityValue))
                .accessibilityHint(Text(String.localizable.watchlistAccessibilityHint))
        }
        .frame(height: Constants.rowHeight)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var poster: some View {
        Group {
            if let posterURL, posterURL.isFileURL, let image = UIImage(contentsOfFile: posterURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if posterURL != nil {
                KFImage(posterURL)
                    .setProcessor(DownsamplingImageProcessor(size: posterDownsamplingSize))
                    .cancelOnDisappear(true)
                    .onFailure { _ in
                        if let posterURL {
                            ImageCache.default.removeImage(forKey: posterURL.cacheKey)
                        }
                    }
                    .placeholder { placeholder }
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Constants.rowHeight)
        .clipped()
        .accessibilityLabel(Text(String(format: String.localizable.watchlistPosterAccessibilityFormat, title)))
    }

    private var placeholder: some View {
        Color(.tertiarySystemBackground)
    }

    private var posterDownsamplingSize: CGSize {
        CGSize(
            width: max(UIScreen.main.bounds.width, Constants.minimumDownsamplingWidth) * displayScale,
            height: Constants.rowHeight * displayScale
        )
    }

    private var watchlistAccessibilityLabel: String {
        String.localizable.watchlistAccessibilityRemove
    }

    private var watchlistAccessibilityValue: String {
        String.localizable.watchlistAccessibilityValueIn
    }
}

private enum Constants {
    static let rowHeight: CGFloat = 250
    static let minimumDownsamplingWidth: CGFloat = 200
    static let overlayOpacity: CGFloat = 0.25
    static let titleStackSpacing: CGFloat = 4
    static let titleLineLimit = 2
    static let contentPadding: CGFloat = 8
}
