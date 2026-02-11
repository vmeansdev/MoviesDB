import MovieDBData
import MovieDBUI
import UIKit

extension TopRatedViewController {
    static func build(
        moviesService: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        output: TopRatedInteractorOutput
    ) -> UIViewController {
        let presenter = TopRatedPresenter(uiAssets: uiAssets)
        let interactor = TopRatedInteractor(
            presenter: presenter,
            service: moviesService,
            watchlistStore: watchlistStore,
            output: output
        )
        let viewController = TopRatedViewController(interactor: interactor)
        presenter.view = viewController
        return viewController
    }
}
