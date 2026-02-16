import Foundation

protocol PosterPrefetchControlling: Actor {
    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int, itemCount: Int, posterURLAt: @Sendable @escaping (Int) -> URL?) async
    func itemCountChanged(columns: Int, itemCount: Int, posterURLAt: @Sendable @escaping (Int) -> URL?) async
    func stop() async
}


actor PosterPrefetchController: PosterPrefetchControlling {
    private let posterImagePrefetcher: any PosterImagePrefetching
    private let prefetchDebounceNanoseconds: UInt64

    private var visibleIndices = Set<Int>()
    private var prefetchTask: Task<Void, Never>?

    init(
        posterImagePrefetcher: any PosterImagePrefetching,
        prefetchDebounceNanoseconds: UInt64 = Constants.prefetchDebounceNanoseconds
    ) {
        self.posterImagePrefetcher = posterImagePrefetcher
        self.prefetchDebounceNanoseconds = prefetchDebounceNanoseconds
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int, itemCount: Int, posterURLAt: @Sendable @escaping (Int) -> URL?) async {
        if isVisible {
            visibleIndices.insert(index)
        } else {
            visibleIndices.remove(index)
        }
        schedulePrefetch(columns: columns, itemCount: itemCount, posterURLAt: posterURLAt)
    }

    func itemCountChanged(columns: Int, itemCount: Int, posterURLAt: @Sendable @escaping (Int) -> URL?) async {
        schedulePrefetch(columns: columns, itemCount: itemCount, posterURLAt: posterURLAt)
    }

    func stop() async {
        prefetchTask?.cancel()
        prefetchTask = nil
        visibleIndices.removeAll(keepingCapacity: true)
        await posterImagePrefetcher.stop()
    }

    private func schedulePrefetch(columns: Int, itemCount: Int, posterURLAt: @Sendable @escaping (Int) -> URL?) {
        prefetchTask?.cancel()
        prefetchTask = Task { [weak self] in
            if let self, self.prefetchDebounceNanoseconds > 0 {
                try? await Task.sleep(nanoseconds: self.prefetchDebounceNanoseconds)
            }
            guard let self, !Task.isCancelled else { return }
            await self.updatePrefetch(columns: columns, itemCount: itemCount, posterURLAt: posterURLAt)
        }
    }

    private func updatePrefetch(columns: Int, itemCount: Int, posterURLAt: @Sendable (Int) -> URL?) async {
        guard itemCount > 0 else {
            await posterImagePrefetcher.stop()
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
        await posterImagePrefetcher.updatePrefetch(urls: urls)
    }

    private func makePrefetchRange(firstVisibleIndex: Int, lastVisibleIndex: Int, totalCount: Int, columns: Int) -> ClosedRange<Int> {
        let safeColumns = max(columns, Constants.minimumColumns)
        let start = max(firstVisibleIndex - safeColumns * Constants.prefetchRowsBehind, 0)
        let end = min(lastVisibleIndex + safeColumns * Constants.prefetchRowsAhead, totalCount - 1)
        return start ... end
    }
}

nonisolated private enum Constants {
    static let minimumColumns = 1
    static let prefetchRowsAhead = 4
    static let prefetchRowsBehind = 2
    static let prefetchDebounceNanoseconds: UInt64 = 120_000_000
}
