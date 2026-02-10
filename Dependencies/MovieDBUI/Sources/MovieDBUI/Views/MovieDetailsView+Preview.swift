#if DEBUG
import SwiftUI

extension MovieDetailsView {
    public enum PreviewData {
        static let imageURL = URL(fileURLWithPath: Bundle.module.path(forResource: "pup", ofType: "jpg")!)
        static let imageData = try! Data(contentsOf: imageURL)
        static let image = UIImage(data: imageData)!
        static let title = "A City in Winter"
        static let subtitle = "2026 • Drama"
        static let overview = "A filmmaker returns home for a single season and discovers the memory of a place is always a story in motion."
        static let viewModel = MovieDetailsViewModel(
            imageURL: imageURL,
            placeholderImage: image,
            title: title,
            subtitle: subtitle,
            overview: overview
        )
        static let frame = CGRect(origin: .zero, size: UIScreen.main.bounds.size)
    }
}

#Preview {
    UIViewPreview {
        let view = MovieDetailsView(frame: MovieDetailsView.PreviewData.frame)
        view.configure(with: MovieDetailsView.PreviewData.viewModel)
        return view
    }.frame(
        width: MovieDetailsView.PreviewData.frame.width,
        height: MovieDetailsView.PreviewData.frame.height
    )
}
#endif
