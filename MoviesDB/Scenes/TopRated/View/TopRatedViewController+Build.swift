import MovieDBData
import UIKit

extension TopRatedViewController {
    static func build(
        moviesService: MoviesServiceProtocol,
        output: TopRatedInteractorOutput
    ) -> UIViewController {
        let presenter = TopRatedPresenter()
        let interactor = TopRatedInteractor(presenter: presenter, service: moviesService, output: output)
        let viewController = TopRatedViewController(interactor: interactor)
        presenter.view = viewController
        return viewController
    }
}
