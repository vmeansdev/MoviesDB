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
            VStack(alignment: .leading, spacing: Constants.contentStackSpacing) {
                header
                detailsCard
                overviewSection
            }
            .padding(.bottom, Constants.contentBottomPadding)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarTitleDisplayMode(.inline)
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
            .padding(Constants.headerPadding)
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
                    .resizable()
                    .scaledToFill()
            }
        } else {
            Rectangle()
                .fill(Color(.secondarySystemBackground))
        }
    }

    private var detailsCard: some View {
        HStack(alignment: .top, spacing: Constants.detailsCardSpacing) {
            VStack(alignment: .leading, spacing: Constants.detailsMetadataSpacing) {
                ForEach(content.metadata) { item in
                    VStack(alignment: .leading, spacing: Constants.detailsMetadataItemSpacing) {
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
            .padding(.top, Constants.detailsCardTopPadding)
        }
        .padding(.horizontal, Constants.detailsCardHorizontalPadding)
        .padding(.top, Constants.detailsCardContentTopPadding)
    }

    private var watchlistButton: some View {
        RoundButtonView(icon: watchlistIcon, tintColor: viewModel.watchlistTintColor) {
            Task { await viewModel.toggleWatchlist() }
        }
        .accessibilityLabel(Text(watchlistAccessibilityLabel))
        .accessibilityValue(Text(watchlistAccessibilityValue))
        .accessibilityHint(Text(MovieDBUILocalizable.string(.watchlistAccessibilityHint)))
        .padding(Constants.watchlistButtonPadding)
    }

    private var watchlistIcon: UIImage? {
        if viewModel.isInWatchlist {
            return viewModel.watchlistFilledIcon ?? viewModel.watchlistIcon
        }
        return viewModel.watchlistIcon
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: Constants.overviewSpacing) {
            Text(content.overviewTitle)
                .font(.title2.weight(.semibold))
            Text(content.overview)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, Constants.overviewHorizontalPadding)
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
    static let contentStackSpacing: CGFloat = 20
    static let contentBottomPadding: CGFloat = 24
    static let headerGradientBottomOpacity: CGFloat = 0.6
    static let headerGradientTopOpacity: CGFloat = 0
    static let headerTitleSpacing: CGFloat = 6
    static let headerTitleSize: CGFloat = 32
    static let headerPadding: CGFloat = 16
    static let headerAspectRatio: CGFloat = 16.0 / 9.0
    static let detailsCardSpacing: CGFloat = 16
    static let detailsMetadataSpacing: CGFloat = 10
    static let detailsMetadataItemSpacing: CGFloat = 2
    static let detailsCardTopPadding: CGFloat = 4
    static let detailsCardHorizontalPadding: CGFloat = 16
    static let detailsCardContentTopPadding: CGFloat = 8
    static let watchlistButtonPadding: CGFloat = 16
    static let overviewSpacing: CGFloat = 10
    static let overviewHorizontalPadding: CGFloat = 16
}
