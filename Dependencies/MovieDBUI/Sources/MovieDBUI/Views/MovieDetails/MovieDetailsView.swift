import Kingfisher
import SwiftUI
import UIKit

public struct MovieDetailsView: View {
    @Bindable private var viewModel: MovieDetailsViewModel

    public init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.mainStackSpacing) {
                header
                detailsCard
                overviewSection
            }
            .padding(.bottom, Constants.bottomPadding)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.container, edges: .top)
        .task { await viewModel.loadDetailsIfNeeded() }
        .onAppear { viewModel.startObserveWatchlist() }
        .onDisappear { viewModel.stopObserveWatchlist() }
    }

    private var content: MovieDetailsContent { viewModel.content }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            headerImage
                .accessibilityLabel(Text(headerImageAccessibilityLabel))
                .accessibilityAddTraits(.isImage)
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(Constants.headerGradientBottomOpacity), Color.black.opacity(Constants.headerGradientTopOpacity)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Constants.headerTitleSpacing) {
                Text(content.title)
                    .font(.system(size: Constants.headerTitleSize, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(Constants.horizontalPadding)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(Constants.headerAspectRatio, contentMode: .fit)
        .clipped()
        .overlay(alignment: .bottomTrailing) {
            if watchlistIcon != nil {
                watchlistButton
            }
        }
    }

    @ViewBuilder
    private var headerImage: some View {
        if let url = content.backdropURL ?? content.posterURL {
            if url.isFileURL,
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                KFImage(url)
                    .onFailure { _ in
                        ImageCache.default.removeImage(forKey: url.cacheKey)
                    }
                    .resizable()
                    .scaledToFill()
            }
        } else {
            Rectangle()
                .fill(Color(.secondarySystemBackground))
        }
    }

    private var detailsCard: some View {
        HStack(alignment: .top, spacing: Constants.detailsHorizontalSpacing) {
            VStack(alignment: .leading, spacing: Constants.detailsVerticalSpacing) {
                ForEach(content.metadata) { item in
                    VStack(alignment: .leading, spacing: Constants.metadataItemSpacing) {
                        Text(item.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(item.value)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(MovieDBUILocalizable.format(.metadataAccessibilityFormat, item.title, item.value)))
                }
            }
            .padding(.top, Constants.detailsTopInset)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.top, Constants.detailsTopPadding)
    }

    private var watchlistButton: some View {
        Button {
            Task { await viewModel.toggleWatchlist() }
        } label: {
            if let icon = watchlistIcon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .foregroundColor(Color(viewModel.watchlistTintColor))
                    .padding(Constants.watchlistIconPadding)
                    .background(Color.black.opacity(Constants.watchlistBackgroundOpacity))
                    .clipShape(Circle())
            }
        }
        .accessibilityLabel(Text(watchlistAccessibilityLabel))
        .accessibilityValue(Text(watchlistAccessibilityValue))
        .accessibilityHint(Text(MovieDBUILocalizable.string(.watchlistAccessibilityHint)))
        .padding(Constants.horizontalPadding)
    }

    private var watchlistIcon: UIImage? {
        if viewModel.isInWatchlist {
            return viewModel.watchlistFilledIcon ?? viewModel.watchlistIcon
        }
        return viewModel.watchlistIcon
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: Constants.detailsVerticalSpacing) {
            Text(content.overviewTitle)
                .font(.title2.weight(.semibold))
            Text(content.overview)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .accessibilityElement(children: .combine)
    }

    private var headerImageAccessibilityLabel: String {
        if content.backdropURL != nil {
            return MovieDBUILocalizable.format(.backdropAccessibilityFormat, content.title)
        }
        return MovieDBUILocalizable.format(.posterAccessibilityFormat, content.title)
    }

    private var watchlistAccessibilityLabel: String {
        viewModel.isInWatchlist
            ? MovieDBUILocalizable.string(.watchlistAccessibilityRemove)
            : MovieDBUILocalizable.string(.watchlistAccessibilityAdd)
    }

    private var watchlistAccessibilityValue: String {
        viewModel.isInWatchlist
            ? MovieDBUILocalizable.string(.watchlistAccessibilityValueIn)
            : MovieDBUILocalizable.string(.watchlistAccessibilityValueOut)
    }
}

private enum Constants {
    static let mainStackSpacing: CGFloat = 20
    static let bottomPadding: CGFloat = 24
    static let headerGradientBottomOpacity: CGFloat = 0.6
    static let headerGradientTopOpacity: CGFloat = 0
    static let headerTitleSpacing: CGFloat = 6
    static let headerTitleSize: CGFloat = 32
    static let headerAspectRatio: CGFloat = 16.0 / 9.0
    static let horizontalPadding: CGFloat = 16
    static let detailsHorizontalSpacing: CGFloat = 16
    static let detailsVerticalSpacing: CGFloat = 10
    static let metadataItemSpacing: CGFloat = 2
    static let detailsTopInset: CGFloat = 4
    static let detailsTopPadding: CGFloat = 8
    static let watchlistIconPadding: CGFloat = 10
    static let watchlistBackgroundOpacity: CGFloat = 0.35
}
