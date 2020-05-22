//
//  DesignQA.swift
//  DesignQA
//
//  Created by Quinn McHenry on 5/18/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

import UIKit

public struct DesignQA {

    public static func doTheQA(view: UIView) {
        
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
    case label(fontName: String, fontSize: CGFloat, maxLines: Int, windowFrame: CGRect?, text: String)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, imageAccessibilityLabel: String?, windowFrame: CGRect?)
    case image(imageAccessibilityLabel: String?, windowFrame: CGRect?)
    
    init?(view: UIView) {
        if let view = view as? UILabel {
            self = QAElement.label(fontName: view.font.fontName,
                                   fontSize: view.font.pointSize,
                                   maxLines: view.numberOfLines,
                                   windowFrame: view.windowFrame,
                                   text: view.text ?? "{empty_text}")
        } else if let view = view as? UIButton {
            let font = view.titleLabel?.font
            self = QAElement.button(fontName: font?.fontName,
                                    fontSize: font?.pointSize,
                                    title: view.titleLabel?.text,
                                    hasImage: view.imageView?.image != nil,
                                    imageAccessibilityLabel: view.imageView?.image?.accessibilityLabel,
                                    windowFrame: view.windowFrame)
        } else if let view = view as? UIImageView {
            self = QAElement.image(imageAccessibilityLabel: view.image?.accessibilityLabel,
                                   windowFrame: view.windowFrame)
        } else {
            return nil
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

