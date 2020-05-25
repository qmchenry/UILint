//
//  UILint.swift
//  UILint
//
//  Created by Quinn McHenry on 5/18/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

import UIKit

public struct UILint {

    public static func lint(view: UIView) {
        
        let screenshot = UIApplication.shared.makeSnapshot()
        if let imageData = screenshot?.pngData() {
            let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("screenshot.png")
            try? imageData.write(to: filename)
            print(filename)
        }
        
        guard let grandparent = view.parentViewController()?.view else {
            print("wah")
            return
        }
                
        func subviews(_ view: UIView) -> [UIView] {
            if let view = view as? UICollectionView {
                return view.visibleCells
            }
            return view.subviews
        }
        
        func recurse(_ view: UIView) -> [QAElement] {
            let viewOutput = [QAElement(view: view)].compactMap{$0}
            return subviews(view).compactMap { recurse($0) }.reduce(viewOutput, +)
        }
        
        print(recurse(grandparent).map{ "\($0)" }.joined(separator: "\n"))
    }
    
}

enum QAElement {
    struct Base {
        let windowFrame: CGRect?
        let zPosition: CGFloat
        init(_ view: UIView) {
            self.windowFrame = view.windowFrame
            self.zPosition = view.layer.zPosition
        }
    }
    case label(fontName: String, fontSize: CGFloat, maxLines: Int, text: String, base: Base)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, imageAccessibilityLabel: String?, base: Base)
    case image(imageAccessibilityLabel: String?, base: Base)
    case other(className: String, base: Base)
    
    init?(view: UIView) {
        let base = Base(view)
        if let view = view as? UILabel {
            self = QAElement.label(fontName: view.font.fontName,
                                   fontSize: view.font.pointSize,
                                   maxLines: view.numberOfLines,
                                   text: view.text ?? "{empty_text}",
                                   base: base)
        } else if let view = view as? UIButton {
            let font = view.titleLabel?.font
            self = QAElement.button(fontName: font?.fontName,
                                    fontSize: font?.pointSize,
                                    title: view.titleLabel?.text,
                                    hasImage: view.imageView?.image != nil,
                                    imageAccessibilityLabel: view.imageView?.image?.accessibilityLabel,
                                    base: base)
        } else if let view = view as? UIImageView {
            self = QAElement.image(imageAccessibilityLabel: view.image?.accessibilityLabel,
                                   base: base)
        } else {
            self = QAElement.other(className: view.className, base: base)
        }
    }
}

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
