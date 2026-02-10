import UIKit

public extension UICollectionView {
    func registerCell<Cell: UICollectionViewCell>(_ type: Cell.Type, reuseIdentifier: String = Cell.defaultReuseIdentifier) {
        register(type, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func dequeueReusableCell<Cell: UICollectionViewCell>(
        _ type: Cell.Type,
        for indexPath: IndexPath,
        reuseIdentifier: String = Cell.defaultReuseIdentifier
    ) -> UICollectionViewCell {
        dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
}

