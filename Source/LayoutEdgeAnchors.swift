//
//  Squidward
//
//  Copyright (c) 2017 - Present QuarkWorks - https://github.com/quarkworks
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

public class LayoutEdgeAnchors {

    /// The top anchor.
    public let top: NSLayoutYAxisAnchor

    /// The left anchor.
    public let left: NSLayoutXAxisAnchor

    /// The bottom anchor.
    public let bottom: NSLayoutYAxisAnchor

    /// The right anchor
    public let right: NSLayoutXAxisAnchor
    
    internal init(top: NSLayoutYAxisAnchor, left: NSLayoutXAxisAnchor,
                bottom: NSLayoutYAxisAnchor, right: NSLayoutXAxisAnchor) {
        
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    /**
     Constrains a list of provided edges to another view's anchors with an inset.
     At least one edge must be constrained.
     
     - parameter edges: The edges that should be constrained.
     - parameter anchors: The the target anchors to be constrained to.
     - parameter inset: An inset that is applied to all the provided edges.
     
     - returns: The newly constructed set of deactivated layout edge constraints.
     */
    public func constraint(edges: UIRectEdge = .all, equalTo anchors: LayoutEdgeAnchors, inset: CGFloat = 0.0) -> LayoutEdgeConstraints {
        return constraint(edges: edges, equalTo: anchors, insets: .init(top: inset, left: inset, bottom: inset, right: inset))
    }

    /**
     Constrains a list of provided edges to another view's anchors with an offset.
     At least one edge must be constrained.

     - parameter edges: The edges that should be constrained.
     - parameter anchors: The the target anchors to be constrained to.
     - parameter offset: An offset that is applied to all the provided edges.

     - returns: The newly constructed set of deactivated layout edge constraints.
     */
    public func constraint(edges: UIRectEdge = .all, equalTo anchors: LayoutEdgeAnchors, offset: UIOffset) -> LayoutEdgeConstraints {
        return constraint(edges: edges, equalTo: anchors, insets: .init(top: offset.vertical, left: offset.horizontal,
                                                                bottom: -offset.vertical, right: -offset.horizontal))
    }

    /**
     Constrains a list of provided edges to another view's anchors with insets.
     At least one edge must be constrained.

     - parameter edges: The edges that should be constrained.
     - parameter anchors: The the target anchors to be constrained to.
     - parameter insets: Insets that is applied to all the provided edges.

     - returns: The newly constructed set of deactivated layout edge constraints.
     */
    public func constraint(edges: UIRectEdge = .all, equalTo anchors: LayoutEdgeAnchors, insets: UIEdgeInsets) -> LayoutEdgeConstraints {

        guard !edges.isEmpty else {
            fatalError("At least one edge must be constrained")
        }

        let topConstraint = edges.contains(.top) ? top.constraint(equalTo: anchors.top, constant: insets.top) : nil
        let leftConstraint = edges.contains(.left) ? left.constraint(equalTo: anchors.left, constant: insets.left) : nil
        let bottomConstraint = edges.contains(.bottom) ? bottom.constraint(equalTo: anchors.bottom, constant: insets.bottom) : nil
        let rightConstraint = edges.contains(.right) ? right.constraint(equalTo: anchors.right, constant: insets.right) : nil
        
        return .init(top: topConstraint, left: leftConstraint, bottom: bottomConstraint, right: rightConstraint)
    }
}

public extension UIView {

    /// A group of edge layout anchors that can be used to create LayoutEdgeConstraints
    public var edgeAnchors: LayoutEdgeAnchors {
        return .init(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}

public class LayoutEdgeConstraints {

    /// The top constraint.
    public let top: NSLayoutConstraint?

    /// The left constraint.
    public let left: NSLayoutConstraint?

    /// The bottom constraint.
    public let bottom: NSLayoutConstraint?

    /// The right constraint.
    public let right: NSLayoutConstraint?

    internal init(top: NSLayoutConstraint?, left: NSLayoutConstraint?, bottom: NSLayoutConstraint?, right: NSLayoutConstraint?) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
    }

    /**
     Inset constrained edges to new value.

     - parameter edges: The edges that the inset should be applied to.
     - parameter inset: The inset to apply.
    */
    public func inset(edges: UIRectEdge = .all, _ inset: CGFloat) {
        if edges.contains(.left) {
            left?.constant = inset
        }

        if edges.contains(.top) {
            top?.constant = inset
        }

        if edges.contains(.right) {
            right?.constant = -inset
        }

        if edges.contains(.bottom) {
            bottom?.constant = -inset
        }
    }

    /**
     Offset constrained edges to a new value.
     
     - parameter offset: The offset to apply.
    */
    public func offset(_ offset: UIOffset) {
        insets = .init(top: -offset.vertical, left: -offset.horizontal,
                       bottom: offset.vertical, right: offset.vertical)
    }

    /// The agregation of all constants of the constraints
    public var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: top?.constant ?? 0,
                                left: left?.constant ?? 0,
                                bottom: bottom?.constant ?? 0,
                                right: right?.constant ?? 0)
        }

        set {
            top?.constant = newValue.top
            left?.constant = newValue.left
            bottom?.constant = -newValue.bottom
            right?.constant = -newValue.right
        }
    }
}

extension LayoutEdgeConstraints: LayoutConstraintGroup {

    public var constraints: [NSLayoutConstraint] {
        return [top, left, bottom, right].flatMap {$0}
    }
}
