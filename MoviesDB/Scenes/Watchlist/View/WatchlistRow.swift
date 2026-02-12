import MovieDBData
import MovieDBUI
import SwiftUI

struct WatchlistRow: View {
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
