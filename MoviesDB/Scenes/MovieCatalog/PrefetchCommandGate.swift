import Foundation

@MainActor
protocol PrefetchCommandGating {
    func markVisible()
    func markHiddenAndStop()
    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int, posterURLs: [URL?])
    func itemCountChanged(columns: Int, posterURLs: [URL?])
}

@MainActor
final class PrefetchCommandGate: PrefetchCommandGating {
    private let controller: any PosterPrefetchControlling
    private var commandTask: Task<Void, Never>?
    private var session: UInt64 = 0
    private var isVisible = false

    init(controller: any PosterPrefetchControlling) {
        self.controller = controller
    }

    func markVisible() {
        isVisible = true
        session &+= 1
    }

    func markHiddenAndStop() {
        isVisible = false
        session &+= 1
        let currentSession = session
        commandTask?.cancel()
        commandTask = Task { [controller] in
            guard !Task.isCancelled else { return }
            let shouldRun = await MainActor.run { [weak self] in
                guard let self else { return false }
                return !self.isVisible && self.session == currentSession
            }
            guard shouldRun, !Task.isCancelled else { return }
            await controller.stop()
        }
    }

    func itemVisibilityChanged(index: Int, isVisible: Bool, columns: Int, posterURLs: [URL?]) {
        let itemCount = posterURLs.count
        enqueue { controller in
            await controller.itemVisibilityChanged(
                index: index,
                isVisible: isVisible,
                columns: columns,
                itemCount: itemCount,
                posterURLAt: { index in
                    guard posterURLs.indices.contains(index) else { return nil }
                    return posterURLs[index]
                }
            )
        }
    }

    func itemCountChanged(columns: Int, posterURLs: [URL?]) {
        let itemCount = posterURLs.count
        enqueue { controller in
            await controller.itemCountChanged(
                columns: columns,
                itemCount: itemCount,
                posterURLAt: { index in
                    guard posterURLs.indices.contains(index) else { return nil }
                    return posterURLs[index]
                }
            )
        }
    }

    private func enqueue(
        _ operation: @escaping @Sendable (any PosterPrefetchControlling) async -> Void
    ) {
        let currentSession = session
        commandTask?.cancel()
        commandTask = Task { [controller] in
            guard !Task.isCancelled else { return }
            let shouldRun = await MainActor.run { [weak self] in
                guard let self else { return false }
                return self.isVisible && self.session == currentSession
            }
            guard shouldRun, !Task.isCancelled else { return }
            await operation(controller)
        }
    }
}
