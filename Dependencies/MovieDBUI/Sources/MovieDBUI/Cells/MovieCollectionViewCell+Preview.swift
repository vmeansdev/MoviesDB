#if DEBUG
import SwiftUI

#Preview {
    UIViewPreview {
        let cell = MovieCollectionViewCell()
        cell.configure(with: MovieCollectionViewCell.PreviewData.viewModel)
        return cell
    }.frame(height: 250)
}

extension MovieCollectionViewCell {
    public enum PreviewData {
        static let viewModel = MovieCollectionViewModel(
            id: "1",
            title: "The Great Expedition",
            subtitle: "2026 • Adventure",
            posterURL: URL(fileURLWithPath: Bundle.module.path(forResource: "pup", ofType: "jpg")!)
        )

        public static func viewModel(with id: String) -> MovieCollectionViewModel {
            MovieCollectionViewModel(
                id: id,
                title: viewModel.title,
                subtitle: viewModel.subtitle,
                posterURL: viewModel.posterURL
            )
        }
    }
}
#endif
