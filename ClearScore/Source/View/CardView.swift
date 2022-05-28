import UIKit

final class CardView: UIView {
    
    var contentView: UIView {
        vibrancyView.contentView
    }

    private let blurEffect = UIBlurEffect(style: .systemThinMaterial)

    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var vibrancyView: UIVisualEffectView = {
        let effect = UIVibrancyEffect(blurEffect: blurEffect, style: .fill)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        
        layer.cornerRadius = 16
        layer.masksToBounds = true

        addSubview(blurView)
        blurView.contentView.addSubview(vibrancyView)
        
        NSLayoutConstraint.activate([
            blurView.leftAnchor.constraint(
                equalTo: leftAnchor
            ),
            blurView.rightAnchor.constraint(
                equalTo: rightAnchor
            ),
            blurView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            blurView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            
            vibrancyView.leftAnchor.constraint(
                equalTo: leftAnchor
            ),
            vibrancyView.rightAnchor.constraint(
                equalTo: rightAnchor
            ),
            vibrancyView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            vibrancyView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }
}
