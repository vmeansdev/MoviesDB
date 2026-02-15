import MovieDBData
import MovieDBUI
import SwiftUI
import UIKit

struct RootView: View {
    @State private var viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        TabView {
            NavigationStack {
                MovieCatalogView(
                    viewModel: viewModel.popularViewModel,
                    posterRenderSizeProvider: viewModel.posterRenderSizeProvider,
                    makeDetailsViewModel: { movie in
                        viewModel.makeMovieDetailsViewModel(
                            movie: movie,
                            isInWatchlist: viewModel.popularViewModel.isInWatchlist(id: movie.id)
                        )
                    }
                )
            }
            .navigationBarTitleDisplayMode(Constants.navigationTitleDisplayMode)
            .tabItem {
                Label {
                    Text(String.localizable.tabPopularTitle)
                } icon: {
                    tabImage(viewModel.tabAssets.popularTabIcon)
                }
            }

            NavigationStack {
                MovieCatalogView(
                    viewModel: viewModel.topRatedViewModel,
                    posterRenderSizeProvider: viewModel.posterRenderSizeProvider,
                    makeDetailsViewModel: { movie in
                        viewModel.makeMovieDetailsViewModel(
                            movie: movie,
                            isInWatchlist: viewModel.topRatedViewModel.isInWatchlist(id: movie.id)
                        )
                    }
                )
            }
            .navigationBarTitleDisplayMode(Constants.navigationTitleDisplayMode)
            .tabItem {
                Label {
                    Text(String.localizable.tabTopRatedTitle)
                } icon: {
                    tabImage(viewModel.tabAssets.topRatedTabIcon)
                }
            }

            NavigationStack {
                WatchlistView(
                    viewModel: viewModel.watchlistViewModel,
                    posterRenderSizeProvider: viewModel.posterRenderSizeProvider,
                    makeDetailsViewModel: { movie in
                        viewModel.makeMovieDetailsViewModel(
                            movie: movie,
                            isInWatchlist: viewModel.watchlistViewModel.isInWatchlist(id: movie.id)
                        )
                    }
                )
                .navigationTitle(String.localizable.tabWatchlistTitle)
            }
            .navigationBarTitleDisplayMode(Constants.navigationTitleDisplayMode)
            .tabItem {
                Label {
                    Text(String.localizable.tabWatchlistTitle)
                } icon: {
                    tabImage(viewModel.tabAssets.watchlistTabIcon)
                }
            }
        }
    }

    @ViewBuilder
    private func tabImage(_ image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image)
                .renderingMode(.template)
        }
    }
}

private enum Constants {
    static let navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode = .inline
}
