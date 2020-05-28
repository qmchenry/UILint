//
//  QAElement.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

enum QAElement {
    case label(font: UIFont, maxLines: Int, text: String, base: Base)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, imageAccessibilityLabel: String?, base: Base)
    case image(imageAccessibilityLabel: String?, base: Base)
    case other(base: Base)

    struct Base {
        let className: String
        let windowFrame: CGRect?
        let tappable: Bool
        let depth: Int
        init(_ view: UIView, depth: Int) {
            self.className = view.className
            self.windowFrame = view.windowFrame
            // This tappable property requires more checks, like for
            // UITapGestureRecognizer specifically, but also for
            // userInteractionEnabled -- we also need to differentiate
            // between tap gesture targets and views that block touches
            // but are not meant to act on them
            tappable = (view.gestureRecognizers?.count ?? 0) > 1
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
    
    func findings(elements: [QAElement], windowSize: CGSize, screenshot: UIImage?) -> [QAFinding] {
        var results = [QAFinding]()
        switch self {
        case .label(let font, let maxLines, let text, let base):
            if let windowFrame = base.windowFrame {
                let croppedScreenshot = screenshot?.crop(to: windowFrame, viewSize: screenshot!.size)
                if isLabelTruncated(text: text, font: font, maxLines: maxLines, frame: windowFrame) {
                    results.append(QAFinding(message: "Label is truncated", severity: .error, screenshot: croppedScreenshot, element: self))
                }
                if isLabelClippedVertically(text: text, font: font, frame: windowFrame) {
                    results.append(QAFinding(message: "Label is clipped vertically", severity: .error, screenshot: croppedScreenshot, element: self))
                }
                if windowSize != .zero && isLabelOffscreen(labelFrame: windowFrame, windowSize: windowSize) {
                    results.append(QAFinding(message: "Label is (partially) offscreen", severity: .error, screenshot: croppedScreenshot, element: self))
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
