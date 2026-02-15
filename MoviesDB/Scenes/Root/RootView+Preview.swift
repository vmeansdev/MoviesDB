import SwiftUI

#Preview {
    let dependencies = DependenciesProvider()
    RootView(viewModel: RootViewModel(dependenciesProvider: dependencies))
}
