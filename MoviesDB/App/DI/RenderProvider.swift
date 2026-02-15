@MainActor
protocol RenderProviderProtocol {
    var posterRenderSizeProvider: any PosterRenderSizeProviding { get }
    var posterImagePrefetcher: any PosterImagePrefetching { get }
    func makePosterPrefetchController() -> any PosterPrefetchControlling
}

@MainActor
final class RenderProvider: RenderProviderProtocol {
    let posterRenderSizeProvider: any PosterRenderSizeProviding
    let posterImagePrefetcher: any PosterImagePrefetching

    init(
        posterRenderSizeProvider: any PosterRenderSizeProviding = PosterRenderSizeProvider(),
        posterImagePrefetcher: any PosterImagePrefetching = PosterImagePrefetcher.shared
    ) {
        self.posterRenderSizeProvider = posterRenderSizeProvider
        self.posterImagePrefetcher = posterImagePrefetcher
    }

    func makePosterPrefetchController() -> any PosterPrefetchControlling {
        PosterPrefetchController(posterImagePrefetcher: posterImagePrefetcher)
    }
}
