//
//  UIKitHelpers.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self))
    }
}

extension UIView {
    func parentViewController() -> UIViewController? {
        if let ancestor = self.next as? UIViewController {
            return ancestor.topmostViewController()
        } else if let ancestor = self.next as? UIView {
            return ancestor.parentViewController()
        } else {
            return nil
        }
    }

    // View's frame in global/window coordinates
    var windowFrame: CGRect? {
        superview?.convert(frame, to: parentViewController()?.view)
    }

    // Return an array of all subviews including those not included in the
    // default subviews property
    var allSubviews: [UIView] {
        if let view = self as? UICollectionView {
            return view.visibleCells
        }
        return subviews
    }

    var consumesTouches: Bool {
        // todo consider multiple points (8 points perimeter and center) but how to handle partial hits?
        // todo handle layer transform
        let hitView = hitTest(CGPoint(x: bounds.size.width/2, y: bounds.size.height/2), with: nil)
        return hitView === self
    }
}

extension UIImage {
    func crop(to rect: CGRect, viewSize: CGSize) -> UIImage {
        let cropScale = max(size.width/viewSize.width, size.height/viewSize.height) * scale
        let cropRect = CGRect(x: rect.origin.x * cropScale,
                              y: rect.origin.y * cropScale,
                              width: rect.size.width * cropScale,
                              height: rect.size.height * cropScale)
        guard let cropped = cgImage?.cropping(to: cropRect) else {
            return UIImage()
        }
        return UIImage(cgImage: cropped)
    }
}

extension UIViewController {
    @objc func topmostViewController() -> UIViewController {
        // Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topmostViewController()
        }
        // Follow responder chain
        for subview in view.subviews {
            if let subViewController = subview.next as? UIViewController {
                return subViewController.topmostViewController()
            }
        }
        return self
    }
}

extension UITabBarController {
    override func topmostViewController() -> UIViewController {
        return selectedViewController?.topmostViewController() ?? self
    }
}

extension UINavigationController {
    override func topmostViewController() -> UIViewController {
        return visibleViewController?.topmostViewController() ?? self
    }
}
