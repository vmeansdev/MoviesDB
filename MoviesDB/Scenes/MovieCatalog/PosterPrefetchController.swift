import Foundation

@MainActor
protocol PosterPrefetchControlling {
    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int, itemCount: Int, posterURLAt: @escaping (Int) -> URL?)
    func itemCountChanged(columns: Int, itemCount: Int, posterURLAt: @escaping (Int) -> URL?)
    func stop()
}

@MainActor
final class PosterPrefetchController: PosterPrefetchControlling {
    private let posterImagePrefetcher: any PosterImagePrefetching

    private var visibleIndices = Set<Int>()
    private var prefetchTask: Task<Void, Never>?

    init(posterImagePrefetcher: any PosterImagePrefetching) {
        self.posterImagePrefetcher = posterImagePrefetcher
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int, itemCount: Int, posterURLAt: @escaping (Int) -> URL?) {
        if isVisible {
            visibleIndices.insert(index)
        } else {
            visibleIndices.remove(index)
        }
        schedulePrefetch(columns: columns, itemCount: itemCount, posterURLAt: posterURLAt)
    }

    func itemCountChanged(columns: Int, itemCount: Int, posterURLAt: @escaping (Int) -> URL?) {
        schedulePrefetch(columns: columns, itemCount: itemCount, posterURLAt: posterURLAt)
    }

    func stop() {
        prefetchTask?.cancel()
        prefetchTask = nil
        visibleIndices.removeAll(keepingCapacity: true)
        posterImagePrefetcher.stop()
    }

    private func schedulePrefetch(columns: Int, itemCount: Int, posterURLAt: @escaping (Int) -> URL?) {
        prefetchTask?.cancel()
        prefetchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: Constants.prefetchDebounceNanoseconds)
            guard let self, !Task.isCancelled else { return }
            self.updatePrefetch(columns: columns, itemCount: itemCount, posterURLAt: posterURLAt)
        }
    }

    private func updatePrefetch(columns: Int, itemCount: Int, posterURLAt: (Int) -> URL?) {
        guard itemCount > 0 else {
            posterImagePrefetcher.stop()
            return
        }
        guard let firstVisibleIndex = visibleIndices.min(), let lastVisibleIndex = visibleIndices.max() else {
            return
        }

        let prefetchRange = makePrefetchRange(
            firstVisibleIndex: firstVisibleIndex,
            lastVisibleIndex: lastVisibleIndex,
            totalCount: itemCount,
            columns: columns
        )
        let urls = prefetchRange.compactMap(posterURLAt)
        posterImagePrefetcher.updatePrefetch(urls: urls)
    }

    private func makePrefetchRange(firstVisibleIndex: Int, lastVisibleIndex: Int, totalCount: Int, columns: Int) -> ClosedRange<Int> {
        let safeColumns = max(columns, Constants.minimumColumns)
        let start = max(firstVisibleIndex - safeColumns * Constants.prefetchRowsBehind, 0)
        let end = min(lastVisibleIndex + safeColumns * Constants.prefetchRowsAhead, totalCount - 1)
        return start ... end
    }
}

private enum Constants {
    static let minimumColumns = 1
    static let prefetchRowsAhead = 4
    static let prefetchRowsBehind = 2
    static let prefetchDebounceNanoseconds: UInt64 = 120_000_000
}
