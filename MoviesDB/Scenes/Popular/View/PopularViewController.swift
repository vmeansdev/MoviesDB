import MovieDBUI
import UIKit

final class PopularViewController: MovieListViewController {
    init(interactor: PopularInteractorProtocol) {
        super.init(interactor: interactor)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var initialTitle: String {
        String(format: String.localizable.popularCountTitle, 0)
    }
}
