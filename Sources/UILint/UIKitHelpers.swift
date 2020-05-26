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
