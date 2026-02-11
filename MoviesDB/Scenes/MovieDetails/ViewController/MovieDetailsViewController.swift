import MovieDBData
import MovieDBUI
import SwiftUI
import UIKit

final class MovieDetailsViewController: UIHostingController<MovieDetailsView> {
    private let viewModel: MovieDetailsViewModel

    init(movie: Movie) {
        viewModel = MovieDetailsViewModel(movie: movie)
        super.init(rootView: MovieDetailsView(viewModel: viewModel))
        view.backgroundColor = .systemBackground
    }

    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(rootView: MovieDetailsView(viewModel: viewModel))
        view.backgroundColor = .systemBackground
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
