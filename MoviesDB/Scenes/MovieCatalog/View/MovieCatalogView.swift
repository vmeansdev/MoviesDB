import MovieDBData
import MovieDBUI
import SwiftUI

struct MovieCatalogView<ViewModel: MovieCatalogViewModelProtocol>: View {
    @Bindable private var viewModel: ViewModel
    @SwiftUI.Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedRoute: MovieDetailsRoute?
    private let viewModelProvider: ViewModelProviderProtocol
    private let posterRenderSizeProvider: any PosterRenderSizeProviding

    init(
        viewModel: ViewModel,
        posterRenderSizeProvider: any PosterRenderSizeProviding,
        viewModelProvider: ViewModelProviderProtocol
    ) {
        self.viewModel = viewModel
        self.posterRenderSizeProvider = posterRenderSizeProvider
        self.viewModelProvider = viewModelProvider
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                catalogContent(for: proxy.size, items: viewModel.state.items)
                stateOverlay
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedRoute) { route in
                MovieDetailsView(viewModel: route.viewModel)
            }
            .task { viewModel.onAppear() }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }

    @ViewBuilder
    private var stateOverlay: some View {
        switch viewModel.state.phase {
        case .idle:
            EmptyView()
        case .initialLoading:
            LoadingStateView()
        case .loadingMore:
            loadingMoreOverlay
        case let .error(details):
            ErrorStateView(
                message: details.message,
                retry: details.retry,
                onClose: { viewModel.dismissError() }
            )
        }
    }

    @ViewBuilder
    private func catalogContent(for size: CGSize, items: [MovieCollectionViewModel]) -> some View {
        if items.isEmpty {
            Color.clear
        } else {
            content(for: size, items: items)
        }
    }

    @ViewBuilder
    private func content(for size: CGSize, items: [MovieCollectionViewModel]) -> some View {
        if MovieGridLayout.shouldUseGridLayout(size: size, horizontalSizeClass: horizontalSizeClass) {
            let columns = MovieGridLayout.gridColumnsCount(size: size)
            let renderSize = posterRenderSizeProvider.size(
                for: size,
                columns: columns,
                itemHeight: Constants.itemHeight,
                minimumColumns: Constants.listColumnsCount
            )
            grid(items: items, columns: columns, posterRenderSize: renderSize)
        } else {
            let renderSize = posterRenderSizeProvider.size(
                for: size,
                columns: Constants.listColumnsCount,
                itemHeight: Constants.itemHeight,
                minimumColumns: Constants.listColumnsCount
            )
            list(items: items, posterRenderSize: renderSize)
        }
    }

    private func list(items: [MovieCollectionViewModel], posterRenderSize: CGSize) -> some View {
        List {
            ForEach(items.indices, id: \.self) { index in
                if let movie = viewModel.movie(at: index) {
                    Button {
                        selectedRoute = MovieDetailsRoute(
                            movie: movie,
                            viewModel: viewModelProvider.makeMovieDetailsViewModel(movie: movie)
                        )
                    } label: {
                        MovieCatalogItemView(
                            model: items[index],
                            height: Constants.itemHeight,
                            posterRenderSize: posterRenderSize,
                            onToggleWatchlist: {
                                viewModel.toggleWatchlist(at: index)
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear { viewModel.itemVisibilityChanged(index: index, isVisible: true, columns: Constants.listColumnsCount) }
                    .onDisappear { viewModel.itemVisibilityChanged(index: index, isVisible: false, columns: Constants.listColumnsCount) }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }

            if !items.isEmpty {
                loadMoreTrigger(itemCount: items.count)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .transaction { transaction in
            transaction.animation = nil
        }
        .task {
            viewModel.updateVisibleColumns(Constants.listColumnsCount)
        }
    }

    private func grid(items: [MovieCollectionViewModel], columns: Int, posterRenderSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: MovieGridLayout.gridColumns(count: columns), spacing: Constants.gridSpacing) {
                ForEach(items.indices, id: \.self) { index in
                    if let movie = viewModel.movie(at: index) {
                        Button {
                            selectedRoute = MovieDetailsRoute(
                                movie: movie,
                                viewModel: viewModelProvider.makeMovieDetailsViewModel(movie: movie)
                            )
                        } label: {
                            MovieCatalogItemView(
                                model: items[index],
                                height: Constants.itemHeight,
                                posterRenderSize: posterRenderSize,
                                onToggleWatchlist: {
                                    viewModel.toggleWatchlist(at: index)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .onAppear { viewModel.itemVisibilityChanged(index: index, isVisible: true, columns: columns) }
                        .onDisappear { viewModel.itemVisibilityChanged(index: index, isVisible: false, columns: columns) }
                    }
                }

                if !items.isEmpty {
                    loadMoreTrigger(itemCount: items.count)
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.loadMoreTriggerHeight)
                }
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
        .task(id: columns) {
            viewModel.updateVisibleColumns(columns)
        }
    }

    private var loadingMoreRow: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding(.vertical, Constants.loadingMoreVerticalPadding)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func loadMoreTrigger(itemCount: Int) -> some View {
        Color.clear
            .frame(height: Constants.loadMoreTriggerHeight)
            .task {
                viewModel.loadMoreIfNeeded(currentIndex: max(itemCount - 1, 0))
            }
    }

    private var loadingMoreOverlay: some View {
        VStack {
            Spacer()
            loadingMoreRow
        }
    }
}

private enum Constants {
    static let itemHeight: CGFloat = 250
    static let gridSpacing: CGFloat = 0
    static let loadingMoreVerticalPadding: CGFloat = 16
    static let loadMoreTriggerHeight: CGFloat = 1
    static let listColumnsCount = 1
}
