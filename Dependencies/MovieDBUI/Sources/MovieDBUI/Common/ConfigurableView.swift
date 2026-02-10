public protocol ConfigurableView {
    associatedtype Item

    func configure(with item: Item)
}
