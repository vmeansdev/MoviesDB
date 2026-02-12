import UIKit

public final class RoundButton: UIControl {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Constants.backgroundColor
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = false
        layer.masksToBounds = false

        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageViewSideLength),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageViewSideLength)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(icon: UIImage?, tintColor: UIColor) {
        imageView.image = icon?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = tintColor
    }

    public func pulse() {
        layer.removeAnimation(forKey: Constants.pulseKey)
        let pulseLayer = CAShapeLayer()
        pulseLayer.frame = bounds
        pulseLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        pulseLayer.fillColor = (backgroundColor ?? Constants.backgroundColor).cgColor
        pulseLayer.opacity = Constants.pulseLayerOpacity
        layer.insertSublayer(pulseLayer, below: imageView.layer)

        let scale = CABasicAnimation(keyPath: Constants.scaleKeyPath)
        scale.fromValue = Constants.pulseScaleFromValue
        scale.toValue = Constants.pulseScaleToValue

        let opacity = CABasicAnimation(keyPath: Constants.opacityKeyPath)
        opacity.fromValue = Constants.pulseOpacityFromValue
        opacity.toValue = Constants.pulseOpacityToValue

        let group = CAAnimationGroup()
        group.animations = [scale, opacity]
        group.duration = Constants.pulseDuration
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        group.isRemovedOnCompletion = true
        pulseLayer.add(group, forKey: Constants.pulseKey)

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.pulseDuration) {
            pulseLayer.removeFromSuperlayer()
        }
    }
}

private enum Constants {
    static let backgroundColor = UIColor.white.withAlphaComponent(0.5)
    static let cornerRadius: CGFloat = 18
    static let imageViewSideLength: CGFloat = 20
    static let pulseKey = "pulse"
    static let scaleKeyPath = "transform.scale"
    static let opacityKeyPath = "opacity"
    static let pulseLayerOpacity: Float = 0.0
    static let pulseScaleFromValue: CGFloat = 1.0
    static let pulseScaleToValue: CGFloat = 1.6
    static let pulseOpacityFromValue: Float = 0.45
    static let pulseOpacityToValue: Float = 0.0
    static let pulseDuration: TimeInterval = 0.45
}
