//
//  UILint.swift
//  UILint
//
//  Created by Quinn McHenry on 5/18/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

import UIKit

public struct UILint {
    
    let elements: [QAElement]
    let findings: [QAFinding]
    let imageData: Data?

    public init?(view: UIView) {
        var currentDepth = 0
        
        let screenshot = UIApplication.shared.makeSnapshot()
        imageData = screenshot?.pngData()
        
        guard let grandparent = view.parentViewController()?.view else {
            print("Unable to find parent view controller from view")
            elements = []
            findings = []
            return
        }
                
        func subviews(_ view: UIView) -> [UIView] {
            if let view = view as? UICollectionView {
                return view.visibleCells
            }
            return view.subviews
        }
        
        func recurse(_ view: UIView) -> [QAElement] {
            let viewOutput = [QAElement(view: view, depth: currentDepth)].compactMap{$0}
            currentDepth += 1
            return subviews(view).compactMap { recurse($0) }.reduce(viewOutput, +)
        }
        
        let elements = recurse(grandparent)
        print(elements.map{ "\($0)" }.joined(separator: "\n"))
        
        let findings = elements.flatMap { $0.findings(elements: elements) }
        print(findings)
        
        self.elements = elements
        self.findings = findings
    }
    
}

enum QAElement {
    case label(font: UIFont, maxLines: Int, text: String, base: Base)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, imageAccessibilityLabel: String?, base: Base)
    case image(imageAccessibilityLabel: String?, base: Base)
    case other(base: Base)

    struct Base {
        let className: String
        let windowFrame: CGRect?
        let depth: Int
        init(_ view: UIView, depth: Int) {
            self.className = view.className
            self.windowFrame = view.windowFrame
            self.depth = depth
        }
    }
    
    var base: Base {
        switch self {
        case .label(_, _, _, let base): return base
        case .button(_, _, _, _, _, let base): return base
        case .image(_, let base): return base
        case .other(let base): return base
        }
    }
    
    var depth: Int {
        return base.depth
    }
    
    func findings(elements: [QAElement]) -> [QAFinding] {
        var results = [QAFinding]()
        switch self {
        case .label(let font, let maxLines, let text, let base):
            if let windowFrame = base.windowFrame {
                if isLabelTruncated(text: text, font: font, maxLines: maxLines, frame: windowFrame) {
                    results.append(QAFinding(message: "Label is truncated", severity: .error, element: self))
                }
            }
        default:
            break
        }
        return results
    }
    
    init?(view: UIView, depth: Int) {
        let base = Base(view, depth: depth)
        if let view = view as? UILabel {
            self = QAElement.label(font: view.font,
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
            self = QAElement.other(base: base)
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
