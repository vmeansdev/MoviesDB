import MovieDBData
import MovieDBUI
import UIKit

extension PopularViewController {
    static func build(
        moviesService: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        output: PopularInteractorOutput
    ) -> UIViewController {
        let mapper = MovieListViewModelMapper(uiAssets: uiAssets)
        let presenter = PopularPresenter(mapper: mapper)
        let interactor = PopularInteractor(
            presenter: presenter,
            service: moviesService,
            watchlistStore: watchlistStore,
            output: output
        )
        let viewController = PopularViewController(interactor: interactor)
        presenter.view = viewController
        return viewController
    }
}
