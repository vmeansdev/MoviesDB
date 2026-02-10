#if DEBUG
import SwiftUI

#Preview {
    ErrorViewController(viewModel: .init(errorMessage: "Something went wrong", retryAction: {}))
}
#endif
