import UIKit

///
/// Passes touch events through to background views. Touches that land on subviews are recognized. Touches that do not land on a sub view are ignored.
///
final class PassthroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            let convertedPoint = convert(point, to: subview)
            if subview.hitTest(convertedPoint, with: event) != nil {
                return true
            }
        }
        return false
    }
}
