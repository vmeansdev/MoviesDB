import MovieDBData
import MovieDBUI
import SwiftUI

struct WatchlistView: View {
    @Bindable private var viewModel: WatchlistViewModel
    @SwiftUI.Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private enum Constants {
        static let gridMinItemWidth: CGFloat = 200
        static let maxGridColumns = 6
        static let minGridColumns = 2
    }

    init(viewModel: WatchlistViewModel) {
        self.viewModel = viewModel
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
            .onAppear { viewModel.startObserveWatchlist() }
            .onDisappear { viewModel.stopObserveWatchlist() }
        }
    }

    private var list: some View {
        List {
            ForEach(viewModel.items, id: \.id) { movie in
                WatchlistRow(
                    movie: movie,
                    heartIcon: viewModel.heartIcon,
                    heartFilledIcon: viewModel.heartFilledIcon,
                    tintColor: viewModel.watchlistTintColor,
                    onSelect: { viewModel.select(movie: movie) },
                    onToggle: { viewModel.toggle(movie: movie) }
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func grid(columns: Int) -> some View {
        ScrollView {
            LazyVGrid(columns: gridColumns(count: columns), spacing: 0) {
                ForEach(viewModel.items, id: \.id) { movie in
                    WatchlistRow(
                        movie: movie,
                        heartIcon: viewModel.heartIcon,
                        heartFilledIcon: viewModel.heartFilledIcon,
                        tintColor: viewModel.watchlistTintColor,
                        onSelect: { viewModel.select(movie: movie) },
                        onToggle: { viewModel.toggle(movie: movie) }
                    )
                }
            }
        }
    }

    private func content(for size: CGSize) -> some View {
        if shouldUseGridLayout(size: size) {
            return AnyView(grid(columns: gridColumnsCount(size: size)))
        }
        return AnyView(list)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            if let icon = viewModel.emptyStateIcon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
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
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func shouldUseGridLayout(size: CGSize) -> Bool {
        if horizontalSizeClass == .regular {
            return true
        }
        if UIDevice.current.userInterfaceIdiom == .phone {
            return size.width > size.height
        }
        return false
    }

    private func gridColumnsCount(size: CGSize) -> Int {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 3
        }
        let availableWidth = max(0, size.width)
        let rawColumns = Int(availableWidth / Constants.gridMinItemWidth)
        let clamped = min(Constants.maxGridColumns, max(Constants.minGridColumns, rawColumns))
        return clamped
    }

    private func gridColumns(count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 0), count: count)
    }
}
