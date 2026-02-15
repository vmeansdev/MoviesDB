import Foundation
import MovieDBData
import MovieDBUI
import UIKit

extension MovieCatalogViewController {
    static func build(
        kind: MovieCatalogKind,
        moviesService: MoviesServiceProtocol,
        watchlistStore: WatchlistStoreProtocol,
        uiAssets: MovieDBUIAssetsProtocol,
        output: MovieCatalogInteractorOutput,
        posterPrefetchController: any PosterPrefetchControlling,
        posterRenderSizeProvider: any PosterRenderSizeProviding,
        posterURLProvider: any PosterURLProviding
    ) -> UIViewController {
        let mapper = MovieCatalogViewModelMapper(uiAssets: uiAssets, posterURLProvider: posterURLProvider)
        let presenter = MovieCatalogPresenter(mapper: mapper, kind: kind)
        let interactor = MovieCatalogInteractor(
            kind: kind,
            presenter: presenter,
            service: moviesService,
            watchlistStore: watchlistStore,
            output: output,
            posterPrefetchController: posterPrefetchController,
            posterRenderSizeProvider: posterRenderSizeProvider,
            posterURLProvider: posterURLProvider,
            language: Locale.current.language.languageCode?.identifier ?? Constants.defaultLanguage
        )
        let viewController = MovieCatalogViewController(interactor: interactor, kind: kind)
        presenter.view = viewController
        return viewController
    }
}

private enum Constants {
    static let defaultLanguage = "en"
}
