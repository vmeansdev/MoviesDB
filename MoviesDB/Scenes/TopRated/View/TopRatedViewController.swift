import MovieDBUI
import UIKit

final class TopRatedViewController: MovieListViewController {
    init(interactor: TopRatedInteractorProtocol) {
        super.init(interactor: interactor)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var initialTitle: String {
        String(format: String.localizable.topRatedCountTitle, 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
