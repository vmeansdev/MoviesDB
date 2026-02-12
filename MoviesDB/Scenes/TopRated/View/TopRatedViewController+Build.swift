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
        let mapper = MovieListViewModelMapper(uiAssets: uiAssets)
        let presenter = TopRatedPresenter(mapper: mapper)
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
