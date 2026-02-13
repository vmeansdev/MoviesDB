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
            VStack(alignment: .leading, spacing: 20) {
                header
                detailsCard
                overviewSection
            }
            .padding(.bottom, 24)
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
                gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0.0)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                Text(content.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16.0 / 9.0, contentMode: .fit)
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
            KFImage(url)
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .fill(Color(.secondarySystemBackground))
        }
    }

    private var detailsCard: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(content.metadata) { item in
                    VStack(alignment: .leading, spacing: 2) {
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
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var watchlistButton: some View {
        Button {
            Task { await viewModel.toggleWatchlist() }
        } label: {
            if let icon = watchlistIcon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .foregroundColor(Color(viewModel.watchlistTintColor))
                    .padding(10)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Circle())
            }
        }
        .accessibilityLabel(Text(watchlistAccessibilityLabel))
        .accessibilityValue(Text(watchlistAccessibilityValue))
        .accessibilityHint(Text(MovieDBUILocalizable.string(.watchlistAccessibilityHint)))
        .padding(16)
    }

    private var watchlistIcon: UIImage? {
        if viewModel.isInWatchlist {
            return viewModel.watchlistFilledIcon ?? viewModel.watchlistIcon
        }
        return viewModel.watchlistIcon
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(content.overviewTitle)
                .font(.title2.weight(.semibold))
            Text(content.overview)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
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
