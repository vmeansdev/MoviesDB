import UIKit

open class CollectionViewCell<Item>: UICollectionViewCell, ConfigurableView {
    open func configure(with item: Item) { }
}

