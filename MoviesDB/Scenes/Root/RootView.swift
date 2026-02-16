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
        let state = viewModel.state

        TabView {
            NavigationStack {
                MovieCatalogView(
                    viewModel: state.popularViewModel,
                    posterRenderSizeProvider: state.posterRenderSizeProvider,
                    viewModelProvider: viewModel.detailsViewModelProvider
                )
            }
            .navigationBarTitleDisplayMode(Constants.navigationTitleDisplayMode)
            .tabItem {
                Label {
                    Text(String.localizable.tabPopularTitle)
                } icon: {
                    tabImage(state.tabAssets.popularTabIcon)
                }
            }

            NavigationStack {
                MovieCatalogView(
                    viewModel: state.topRatedViewModel,
                    posterRenderSizeProvider: state.posterRenderSizeProvider,
                    viewModelProvider: viewModel.detailsViewModelProvider
                )
            }
            .navigationBarTitleDisplayMode(Constants.navigationTitleDisplayMode)
            .tabItem {
                Label {
                    Text(String.localizable.tabTopRatedTitle)
                } icon: {
                    tabImage(state.tabAssets.topRatedTabIcon)
                }
            }

            NavigationStack {
                WatchlistView(
                    viewModel: state.watchlistViewModel,
                    posterRenderSizeProvider: state.posterRenderSizeProvider,
                    viewModelProvider: viewModel.detailsViewModelProvider
                )
                .navigationTitle(String.localizable.tabWatchlistTitle)
            }
            .navigationBarTitleDisplayMode(Constants.navigationTitleDisplayMode)
            .tabItem {
                Label {
                    Text(String.localizable.tabWatchlistTitle)
                } icon: {
                    tabImage(state.tabAssets.watchlistTabIcon)
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
