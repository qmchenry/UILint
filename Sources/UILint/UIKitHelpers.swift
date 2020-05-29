//
//  UIKitHelpers.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension UIView {
    func parentViewController() -> UIViewController? {
        if let ancestor = self.next as? UIViewController {
            return ancestor
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
}

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self))
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
