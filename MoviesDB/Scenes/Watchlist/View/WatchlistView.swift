import MovieDBData
import MovieDBUI
import SwiftUI

struct WatchlistView: View {
    @Bindable private var viewModel: WatchlistViewModel

    init(viewModel: WatchlistViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.items.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .background(Color(.systemBackground))
    }

    private var list: some View {
        List {
            ForEach(viewModel.items, id: \.id) { movie in
                WatchlistRow(
                    movie: movie,
                    heartIcon: viewModel.heartIcon,
                    heartFilledIcon: viewModel.heartFilledIcon,
                    tintColor: viewModel.watchlistTintColor,
                    onSelect: { viewModel.select(movie: movie) },
                    onToggle: { viewModel.toggle(movie: movie) }
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            if let icon = viewModel.emptyStateIcon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(Text(String.localizable.watchlistEmptyIconAccessibilityLabel))
            }
            Text(String.localizable.watchlistEmptyTitle)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(String.localizable.watchlistEmptySubtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct WatchlistRow: View {
    let movie: Movie
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
                    .fill(Color.black.opacity(0.25))
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                        Text(releaseDate)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(8)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            RoundButtonView(icon: heartFilledIcon, tintColor: tintColor, action: onToggle)
                .padding(8)
                .contentShape(Circle())
                .highPriorityGesture(TapGesture().onEnded(onToggle))
                .accessibilityLabel(Text(watchlistAccessibilityLabel))
                .accessibilityValue(Text(watchlistAccessibilityValue))
                .accessibilityHint(Text(String.localizable.watchlistAccessibilityHint))
        }
        .frame(height: 250)
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .contentShape(Rectangle())
    }

    private var poster: some View {
        AsyncImage(url: posterURL) { phase in
            switch phase {
            case let .success(image):
                image.resizable().scaledToFill()
            case .empty:
                Color(.tertiarySystemBackground)
            case .failure:
                Color(.tertiarySystemBackground)
            @unknown default:
                Color(.tertiarySystemBackground)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .clipped()
        .accessibilityLabel(Text(String(format: String.localizable.watchlistPosterAccessibilityFormat, movie.title)))
    }

    private var posterURL: URL? {
        guard !movie.posterPath.isEmpty else { return nil }
        return URL(string: "\(Environment.imageBaseURLString)/t/p/w500\(movie.posterPath)")
    }

    private var watchlistAccessibilityLabel: String {
        String.localizable.watchlistAccessibilityRemove
    }

    private var watchlistAccessibilityValue: String {
        String.localizable.watchlistAccessibilityValueIn
    }
}
