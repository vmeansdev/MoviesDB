import MovieDBData
import MovieDBUI
import Observation

@MainActor
@Observable
final class RootViewModel {
    private(set) var state: RootViewModelState

    private let viewModelProvider: ViewModelProviderProtocol

    init(dependenciesProvider: DependenciesProviderProtocol) {
        self.viewModelProvider = dependenciesProvider.viewModelProvider
        self.state = .ready(
            popularViewModel: viewModelProvider.makeMovieCatalogViewModel(kind: .popular),
            topRatedViewModel: viewModelProvider.makeMovieCatalogViewModel(kind: .topRated),
            watchlistViewModel: viewModelProvider.makeWatchlistViewModel(),
            posterRenderSizeProvider: dependenciesProvider.renderProvider.posterRenderSizeProvider,
            tabAssets: dependenciesProvider.assetsProvider.uiAssets
        )
    }

    func makeMovieDetailsViewModel(movie: Movie) -> MovieDetailsViewModel {
        viewModelProvider.makeMovieDetailsViewModel(movie: movie)
    }

    var detailsViewModelProvider: ViewModelProviderProtocol {
        viewModelProvider
    }
}

enum RootViewModelState {
    case ready(
        popularViewModel: MovieCatalogViewModel,
        topRatedViewModel: MovieCatalogViewModel,
        watchlistViewModel: WatchlistViewModel,
        posterRenderSizeProvider: any PosterRenderSizeProviding,
        tabAssets: MovieDBUIAssetsProtocol
    )

    var popularViewModel: MovieCatalogViewModel {
        switch self {
        case let .ready(popularViewModel, _, _, _, _):
            return popularViewModel
        }
    }

    var topRatedViewModel: MovieCatalogViewModel {
        switch self {
        case let .ready(_, topRatedViewModel, _, _, _):
            return topRatedViewModel
        }
    }

    var watchlistViewModel: WatchlistViewModel {
        switch self {
        case let .ready(_, _, watchlistViewModel, _, _):
            return watchlistViewModel
        }
    }

    var posterRenderSizeProvider: any PosterRenderSizeProviding {
        switch self {
        case let .ready(_, _, _, posterRenderSizeProvider, _):
            return posterRenderSizeProvider
        }
    }

    var tabAssets: MovieDBUIAssetsProtocol {
        switch self {
        case let .ready(_, _, _, _, tabAssets):
            return tabAssets
        }
    }
}
