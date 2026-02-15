import MovieDBUI
import UIKit

final class MovieCatalogViewController: MovieCatalogCollectionViewController {
    private let kind: MovieCatalogKind

    init(interactor: MovieCatalogInteractorProtocol, kind: MovieCatalogKind) {
        self.kind = kind
        super.init(interactor: interactor)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var initialTitle: String {
        kind.title(count: 0)
    }
}
