import MovieDBUI

@MainActor
protocol AssetsProviderProtocol {
    var uiAssets: MovieDBUIAssetsProtocol { get }
}

final class AssetsProvider: AssetsProviderProtocol {
    let uiAssets: MovieDBUIAssetsProtocol

    init(uiAssets: MovieDBUIAssetsProtocol = MovieDBUIAssets.system) {
        self.uiAssets = uiAssets
    }
}
