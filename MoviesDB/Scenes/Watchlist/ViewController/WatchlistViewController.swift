import SwiftUI
import UIKit

final class WatchlistViewController: UIHostingController<WatchlistView> {
    init(with rootView: WatchlistView) {
        super.init(rootView: rootView)
        view.backgroundColor = .systemBackground
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .automatic
    }
}
