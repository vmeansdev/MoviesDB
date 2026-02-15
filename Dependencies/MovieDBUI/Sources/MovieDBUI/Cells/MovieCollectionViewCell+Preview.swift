#if DEBUG
import SwiftUI
import UIKit

#Preview {
    UIViewPreview {
        let cell = MovieCollectionViewCell()
        cell.configure(with: MovieCollectionViewCell.PreviewData.viewModel)
        return cell
    }.frame(height: Constants.previewHeight)
}

extension MovieCollectionViewCell {
    public enum PreviewData {
        @MainActor static let viewModel = MovieCollectionViewModel(
            id: "1",
            title: "The Great Expedition",
            subtitle: "2026 • Adventure",
            posterURL: URL(fileURLWithPath: Bundle.module.path(forResource: "pup", ofType: "jpg")!),
            watchlistIcon: UIImage(systemName: "heart"),
            watchlistSelectedIcon: nil,
            watchlistTintColor: .systemPink,
            isInWatchlist: false
        )

        @MainActor public static func viewModel(with id: String) -> MovieCollectionViewModel {
            MovieCollectionViewModel(
                id: id,
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                posterURL: viewModel.posterURL,
                watchlistIcon: viewModel.watchlistIcon,
                watchlistSelectedIcon: viewModel.watchlistSelectedIcon,
                watchlistTintColor: viewModel.watchlistTintColor,
                isInWatchlist: viewModel.isInWatchlist
            )
        }
    }
}

private enum Constants {
    static let previewHeight: CGFloat = 250
}
#endif
