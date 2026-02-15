import MovieDBData
import MovieDBUI
import SwiftUI

struct WatchlistView: View {
    @Bindable private var viewModel: WatchlistViewModel
    @SwiftUI.Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let posterRenderSizeProvider: any PosterRenderSizeProviding
    let makeDetailsViewModel: (Movie) -> MovieDetailsViewModel
    @State private var selectedRoute: MovieDetailsRoute?

    init(
        viewModel: WatchlistViewModel,
        posterRenderSizeProvider: any PosterRenderSizeProviding,
        makeDetailsViewModel: @escaping (Movie) -> MovieDetailsViewModel
    ) {
        self.viewModel = viewModel
        self.posterRenderSizeProvider = posterRenderSizeProvider
        self.makeDetailsViewModel = makeDetailsViewModel
    }

    var body: some View {
        GeometryReader { proxy in
            Group {
                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    content(for: proxy.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedRoute) { route in
                MovieDetailsView(viewModel: route.viewModel)
            }
            .onAppear { viewModel.startObserveWatchlist() }
            .onDisappear { viewModel.stopObserveWatchlist() }
        }
    }

    private func list(posterRenderSize: CGSize) -> some View {
        List {
            ForEach(viewModel.itemViewModels.indices, id: \.self) { index in
                if let movie = viewModel.movie(at: index) {
                    Button {
                        selectedRoute = MovieDetailsRoute(movie: movie, viewModel: makeDetailsViewModel(movie))
                    } label: {
                        MovieCatalogItemView(
                            model: viewModel.itemViewModels[index],
                            height: Constants.itemHeight,
                            posterRenderSize: posterRenderSize,
                            onToggleWatchlist: {
                                viewModel.toggle(movie: movie)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear { viewModel.itemVisibilityChanged(index: index, isVisible: true, columns: Constants.listColumnsCount) }
                    .onDisappear { viewModel.itemVisibilityChanged(index: index, isVisible: false, columns: Constants.listColumnsCount) }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .onChange(of: viewModel.itemViewModels.count) { _, _ in
            viewModel.itemsCountChanged(columns: Constants.listColumnsCount)
        }
    }

    private func grid(columns: Int, posterRenderSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: MovieGridLayout.gridColumns(count: columns), spacing: Constants.gridSpacing) {
                ForEach(viewModel.itemViewModels.indices, id: \.self) { index in
                    if let movie = viewModel.movie(at: index) {
                        Button {
                            selectedRoute = MovieDetailsRoute(movie: movie, viewModel: makeDetailsViewModel(movie))
                        } label: {
                            MovieCatalogItemView(
                                model: viewModel.itemViewModels[index],
                                height: Constants.itemHeight,
                                posterRenderSize: posterRenderSize,
                                onToggleWatchlist: {
                                    viewModel.toggle(movie: movie)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .onAppear { viewModel.itemVisibilityChanged(index: index, isVisible: true, columns: columns) }
                        .onDisappear { viewModel.itemVisibilityChanged(index: index, isVisible: false, columns: columns) }
                    }
                }
            }
        }
        .onChange(of: viewModel.itemViewModels.count) { _, _ in
            viewModel.itemsCountChanged(columns: columns)
        }
    }

    @ViewBuilder
    private func content(for size: CGSize) -> some View {
        if MovieGridLayout.shouldUseGridLayout(size: size, horizontalSizeClass: horizontalSizeClass) {
            let columns = MovieGridLayout.gridColumnsCount(size: size)
            let renderSize = posterRenderSizeProvider.size(
                for: size,
                columns: columns,
                itemHeight: Constants.itemHeight,
                minimumColumns: Constants.listColumnsCount
            )
            grid(columns: columns, posterRenderSize: renderSize)
        }
        else {
            let renderSize = posterRenderSizeProvider.size(
                for: size,
                columns: Constants.listColumnsCount,
                itemHeight: Constants.itemHeight,
                minimumColumns: Constants.listColumnsCount
            )
            list(posterRenderSize: renderSize)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Constants.emptyStateSpacing) {
            if let icon = viewModel.emptyStateIcon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Constants.emptyStateIconSize, height: Constants.emptyStateIconSize)
                    .foregroundColor(.secondary)
                    .accessibilityLabel(Text(String.localizable.watchlistEmptyIconAccessibilityLabel))
            }
            Text(String.localizable.watchlistEmptyTitle)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(String.localizable.watchlistEmptySubtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(Constants.emptyStatePadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

private enum Constants {
    static let itemHeight: CGFloat = 250
    static let gridSpacing: CGFloat = 0
    static let emptyStateSpacing: CGFloat = 16
    static let emptyStateIconSize: CGFloat = 56
    static let emptyStatePadding: CGFloat = 24
    static let listColumnsCount = 1
}
