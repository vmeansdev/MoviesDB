import UIKit

extension UIViewController {
    public func attach(_ child: UIViewController) {
        addChild(child)
        child.view.frame = view.bounds
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    public func detach() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

