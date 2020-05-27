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
        superview?.convert(frame, to: nil)
    }
}

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self))
    }
}

extension UIImage {
    func crop(to rect: CGRect, viewSize: CGSize) -> UIImage {
        let scale = max(size.width/viewSize.width, size.height/viewSize.height)
        let cropRect = CGRect(x: rect.origin.x * scale,
                              y: rect.origin.y * scale,
                              width: rect.size.width * scale,
                              height: rect.size.height * scale)
        guard let cropped = cgImage?.cropping(to: cropRect) else {
            return UIImage()
        }
        return UIImage(cgImage: cropped)
    }
}
