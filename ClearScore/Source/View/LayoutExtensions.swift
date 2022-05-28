import UIKit

extension NSLayoutDimension {
    static func ==(lhs: NSLayoutDimension, rhs: NSLayoutDimension) -> NSLayoutConstraint {
        lhs.constraint(equalTo: rhs)
    }
    
    static func >=(lhs: NSLayoutDimension, rhs: NSLayoutDimension) -> NSLayoutConstraint {
        lhs.constraint(greaterThanOrEqualTo: rhs)
    }
    
    static func <=(lhs: NSLayoutDimension, rhs: NSLayoutDimension) -> NSLayoutConstraint {
        lhs.constraint(lessThanOrEqualTo: rhs)
    }
    
    static func ==(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
        lhs.constraint(equalToConstant: rhs)
    }
    
    static func >=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
        lhs.constraint(greaterThanOrEqualToConstant: rhs)
    }
    
    static func <=(lhs: NSLayoutDimension, rhs: CGFloat) -> NSLayoutConstraint {
        lhs.constraint(lessThanOrEqualToConstant: rhs)
    }
}

extension NSLayoutXAxisAnchor {
    static func ==(lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
        lhs.constraint(equalTo: rhs)
    }
    
    static func >=(lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
        lhs.constraint(greaterThanOrEqualTo: rhs)
    }
    
    static func <=(lhs: NSLayoutXAxisAnchor, rhs: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
        lhs.constraint(lessThanOrEqualTo: rhs)
    }
}

extension NSLayoutYAxisAnchor {
    static func ==(lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
        lhs.constraint(equalTo: rhs)
    }
    
    static func >=(lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
        lhs.constraint(greaterThanOrEqualTo: rhs)
    }
    
    static func <=(lhs: NSLayoutYAxisAnchor, rhs: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
        lhs.constraint(lessThanOrEqualTo: rhs)
    }
}

extension NSLayoutConstraint {
    
    static func +(lhs: NSLayoutConstraint, rhs: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: lhs.firstItem as Any,
            attribute: lhs.firstAttribute,
            relatedBy: lhs.relation,
            toItem: lhs.secondItem,
            attribute: lhs.secondAttribute,
            multiplier: lhs.multiplier,
            constant: +rhs
        )
    }
    
    static func -(lhs: NSLayoutConstraint, rhs: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: lhs.firstItem as Any,
            attribute: lhs.firstAttribute,
            relatedBy: lhs.relation,
            toItem: lhs.secondItem,
            attribute: lhs.secondAttribute,
            multiplier: lhs.multiplier,
            constant: -rhs
        )
    }

    static func *(lhs: NSLayoutConstraint, rhs: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: lhs.firstItem as Any,
            attribute: lhs.firstAttribute,
            relatedBy: lhs.relation,
            toItem: lhs.secondItem,
            attribute: lhs.secondAttribute,
            multiplier: rhs,
            constant: lhs.constant
        )
    }
}


func constraints(@ConstraintBuilder builder: () -> [NSLayoutConstraint]) {
    NSLayoutConstraint.activate(builder())
}


@resultBuilder struct ConstraintBuilder {
    static func buildBlock(_ components: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        components
    }
}
