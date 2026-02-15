import MovieDBData
import MovieDBUI
import SwiftUI
import UIKit

struct MovieCatalogView<ViewModel: MovieCatalogViewModelProtocol>: View {
    @Bindable private var viewModel: ViewModel
    @SwiftUI.Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let makeDetailsViewModel: (Movie) -> MovieDetailsViewModel
    private let posterRenderSizeProvider: any PosterRenderSizeProviding
    @State private var selectedRoute: MovieDetailsRoute?

    init(
        viewModel: ViewModel,
        posterRenderSizeProvider: any PosterRenderSizeProviding,
        makeDetailsViewModel: @escaping (Movie) -> MovieDetailsViewModel
    ) {
        self.viewModel = viewModel
        self.posterRenderSizeProvider = posterRenderSizeProvider
        self.makeDetailsViewModel = makeDetailsViewModel
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Group {
                    if viewModel.items.isEmpty {
                        emptyState
                    } else {
                        content(for: proxy.size)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if viewModel.isInitialLoading {
                    LoadingStateView()
                }

                if viewModel.isLoadingMore {
                    loadingMoreOverlay
                }

                if let error = viewModel.error {
                    ErrorStateView(
                        message: error.message,
                        retry: error.retry,
                        onClose: { viewModel.dismissError() }
                    )
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedRoute) { route in
                MovieDetailsView(viewModel: route.viewModel)
            }
            .onAppear { viewModel.onAppear() }
            .onDisappear {
                viewModel.onDisappear()
            }
        }
    }

    private var emptyState: some View {
        AnyView(Color.clear)
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

    private func list(posterRenderSize: CGSize) -> some View {
        List {
            ForEach(viewModel.items.indices, id: \.self) { index in
                if let movie = viewModel.movie(at: index) {
                    Button {
                        selectedRoute = MovieDetailsRoute(movie: movie, viewModel: makeDetailsViewModel(movie))
                    } label: {
                        MovieCatalogItemView(
                            model: viewModel.items[index],
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

            if !viewModel.items.isEmpty {
                loadMoreTrigger
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
        .onChange(of: viewModel.items.count) { _, _ in
            viewModel.itemsCountChanged(columns: Constants.listColumnsCount)
        }
    }

    private func grid(columns: Int, posterRenderSize: CGSize) -> some View {
        ScrollView {
            LazyVGrid(columns: MovieGridLayout.gridColumns(count: columns), spacing: Constants.gridSpacing) {
                ForEach(viewModel.items.indices, id: \.self) { index in
                    if let movie = viewModel.movie(at: index) {
                        Button {
                            selectedRoute = MovieDetailsRoute(movie: movie, viewModel: makeDetailsViewModel(movie))
                        } label: {
                            MovieCatalogItemView(
                                model: viewModel.items[index],
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

                if !viewModel.items.isEmpty {
                    loadMoreTrigger
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.loadMoreTriggerHeight)
                }
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
        .onChange(of: viewModel.items.count) { _, _ in
            viewModel.itemsCountChanged(columns: columns)
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

    private var loadMoreTrigger: some View {
        Color.clear
            .frame(height: Constants.loadMoreTriggerHeight)
            .onAppear {
                viewModel.loadMoreIfNeeded(currentIndex: max(viewModel.items.count - 1, 0))
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
