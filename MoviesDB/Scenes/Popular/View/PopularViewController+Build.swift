import MovieDBData
import UIKit

extension PopularViewController {
    static func build(
        moviesService: MoviesServiceProtocol,
        output: PopularInteractorOutput
    ) -> UIViewController {
        let presenter = PopularPresenter()
        let interactor = PopularInteractor(presenter: presenter, service: moviesService, output: output)
        let viewController = PopularViewController(interactor: interactor)
        presenter.view = viewController
        return viewController
    }
}
