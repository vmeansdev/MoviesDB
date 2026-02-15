import SwiftUI
import UIKit

#Preview {
    UIViewPreview {
        let label = UILabel()
        label.text = "Preview"
        label.textColor = .label
        label.backgroundColor = .secondarySystemBackground
        label.textAlignment = .center
        label.frame = CGRect(origin: .zero, size: CGSize(width: Constants.labelWidth, height: Constants.labelHeight))
        return label
    }
    .frame(width: Constants.labelWidth, height: Constants.labelHeight)
}

private enum Constants {
    static let labelWidth: CGFloat = 120
    static let labelHeight: CGFloat = 44
}
