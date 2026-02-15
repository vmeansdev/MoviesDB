import SwiftUI

@main
struct MoviesDBApp: App {
    @State private var rootViewModel = RootViewModel(dependenciesProvider: DependenciesProvider())

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: rootViewModel)
        }
    }
}
