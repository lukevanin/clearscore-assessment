import UIKit

typealias Radians = CGFloat


extension Radians {
    static var tau: Radians {
        .pi * 2
    }
}

///
/// Displays an animatable line in the shape of an arc. The arc is rendered with a gap (configurable). The`progress` value indicates how mich of the arc to
/// render, as a fraction of the distance across the gap.
///
private final class ArcLayer: CALayer {
    
    /// Value between 0 and 1 inclusive, specifying how much of the arc to show. The arc is rendered as a fraction of the total length of the arc from the leading
    /// edge of the gap to the trailing edge.
    @NSManaged var progress: CGFloat
    
    /// Amount of space that is left empty between the ends of the arc.
    @NSManaged var gap: Radians
    
    /// Thickness of the line used to render the arc, in screen points.
    @NSManaged var thickness: CGFloat
    
    /// Color of the line of the arc.
    @NSManaged var color: CGColor?
    
    private let shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineCap = .round
        return layer
    }()

    override init() {
        super.init()
        addSublayer(shapeLayer)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let layer = layer as? Self {
            for key in Self.animationKeys {
                let value = layer.value(forKeyPath: key)
                setValue(value, forKeyPath: key)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSublayer(shapeLayer)
    }
    
    override func display() {
        guard let presentation = presentation() else {
            return
        }
        
        // Compute the radius of the arc so that it fits within the width and height of the available display area.
        let radius = (min(bounds.width, bounds.height) * 0.5) - (presentation.thickness * 0.5)
        
        // Compute the start and end angle of the arc. The potential path for the arc starts at one side of the
        // gap, continues around the circle, and ends at the other side of the gap. The visible arc is rendered as a
        // fraction of the potential arc according to the fraction specified by the progress value.
        let startAngle = (.pi * 0.5) + (presentation.gap * 0.5)
        let endAngle = startAngle + (.tau - presentation.gap) * presentation.progress
        let arcCenter = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)

        let path = UIBezierPath(
            arcCenter: arcCenter,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        shapeLayer.frame = bounds
        shapeLayer.strokeColor = presentation.color
        shapeLayer.lineWidth = presentation.thickness
        shapeLayer.path = path.cgPath
    }

    override func action(forKey event: String) -> CAAction? {
        if Self.isAnimationKeySupported(event) {
            // Create a CAAnimation for the given key.
            let context = currentAnimationContext()
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = context?.duration ?? .zero
            animation.timingFunction = context?.timingFunction
            if let presentation = presentation() {
                animation.fromValue = presentation.value(forKeyPath: event)
            }
            return animation
        }
        
        return super.action(forKey: event)
    }
    
    private func currentAnimationContext() -> CABasicAnimation? {
        /// The UIView animation implementation is private, so to check if the view is animating and
        /// get its property keys we can use the key "backgroundColor" since its been a property of
        /// UIView which has been forever and returns a CABasicAnimation.
        return action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if isAnimationKeySupported(key) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    private class func isAnimationKeySupported(_ key: String) -> Bool {
        return animationKeys.contains(key)
    }

    private static let animationKeys = [
        #keyPath(progress),
        #keyPath(gap),
        #keyPath(thickness),
        #keyPath(color)
    ]
}


///
/// Displays a line in the shape of an arc (partial circle).
///
final class ArcView: UIView {
    
    @objc dynamic var value: CGFloat {
        get {
            arcLayer.progress
        }
        set {
            arcLayer.progress = newValue
        }
    }
    
    @objc dynamic var gap: Radians {
        get {
            arcLayer.gap
        }
        set {
            arcLayer.gap = newValue
        }
    }
    
    @objc dynamic var color: UIColor? {
        get {
            arcLayer.color.flatMap { UIColor(cgColor: $0) }
        }
        set {
            arcLayer.color = newValue?.cgColor
        }
    }
    
    @objc dynamic var thickness: CGFloat {
        get {
            arcLayer.thickness
        }
        set {
            arcLayer.thickness = newValue
        }
    }
    
    private var arcLayer: ArcLayer {
        layer as! ArcLayer
    }
    
    override class var layerClass: AnyClass {
        ArcLayer.self
    }
}
