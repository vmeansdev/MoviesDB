import MovieDBData
import MovieDBUI
import SwiftUI
import UIKit

final class MovieDetailsCoordinator: Coordinator {
    private let rootViewController: UINavigationController
    private let movie: Movie

    init(rootViewController: UINavigationController, movie: Movie) {
        self.rootViewController = rootViewController
        self.movie = movie
    }

    func start() {
        let viewController = MovieDetailsViewController(movie: movie)
        rootViewController.pushViewController(viewController, animated: true)
    }
}
