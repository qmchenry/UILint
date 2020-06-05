//
//  QAElement.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

enum QAElement: Comparable {
    
    case label(font: UIFont, maxLines: Int, text: String, minimumScaleFactor: CGFloat, base: Base)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, imageAccessibilityLabel: String?, base: Base)
    case image(image: UIImage?, imageAccessibilityLabel: String?, base: Base)
    case other(base: Base)

    struct Base {
        let className: String
        let windowFrame: CGRect?
        let wantsTouches: Bool // like a button
        let consumesTouches: Bool // opaque view that blocks
        let depth: Int
        let contentScaleFactor: CGFloat
        let contentMode: UIView.ContentMode
        init(_ view: UIView, depth: Int) {
            self.className = view.className
            self.windowFrame = view.windowFrame
            let enabledGestureRecognizers = view.gestureRecognizers?.filter { $0.isEnabled }.count ?? 0
            wantsTouches = (view is UIControl) || enabledGestureRecognizers > 0
            consumesTouches = view.consumesTouches
            self.depth = depth
            contentScaleFactor = view.contentScaleFactor
            contentMode = view.contentMode
        }
    }
    
    var base: Base {
        switch self {
        case .label(_, _, _, _, let base): return base
        case .button(_, _, _, _, _, let base): return base
        case .image(_, _, let base): return base
        case .other(let base): return base
        }
    }
    
    var depth: Int {
        return base.depth
    }
    
    var sortOrder: Int {
        switch self {
        case .label: return 100
        case .button: return 200
        case .image: return 300
        case .other: return 10000
        }
    }
    
    var isLabel: Bool { sortOrder == 100 }
        
    func findings(elements: [QAElement], windowSize: CGSize, screenshot: UIImage?) -> [QAFinding] {
        var results = [QAFinding]()
        switch self {
        case .label(let font, let maxLines, let text, _, let base):
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
                elements.filter { $0.isLabel && $0.depth > depth }.forEach { element in
                    // considering only depths > self's depth prevents duplication of findings as they both overlap each other and also checking against self
                    if overlaps(element) {
                        let unionBounds = windowFrame.union(element.base.windowFrame!)
                        let croppedScreenshot = screenshot?.crop(to: unionBounds, viewSize: screenshot!.size)
                        results.append(QAFinding(message: "\(base.className) overlaps \(element.base.className)", severity: .warning, screenshot: croppedScreenshot, element: self))
                    }
                }

            }
        default:
            break
        }
        
        // Tappability check
        if base.wantsTouches, let windowFrame = base.windowFrame {
            // Overlapping tap consumers
            let overlapping = elements.filter { $0.base.depth > base.depth && $0.base.consumesTouches }
            overlapping.forEach { element in
                if overlaps(element) {
                    let unionBounds = windowFrame.union(element.base.windowFrame!)
                    let croppedScreenshot = screenshot?.crop(to: unionBounds, viewSize: screenshot!.size)
                    results.append(QAFinding(message: "Tappable view \(base.className) is obscured by \(element.base.className)", severity: .error, screenshot: croppedScreenshot, element: self))
                }
            }
            
            // Minimum tappable size
            if windowFrame.size.height < 44 || windowFrame.size.width < 44 {
                let croppedScreenshot = screenshot?.crop(to: windowFrame, viewSize: screenshot!.size)
                results.append(QAFinding(message: "Provide ample touch targets for interactive elements. \(base.className) width/height is less than 44pt (\(windowFrame.width),\(windowFrame.height))", severity: .error, screenshot: croppedScreenshot, element: self))
            }
        }
        
        return results
    }
    
    func overlaps(_ element: QAElement) -> Bool {
        guard let windowFrame = base.windowFrame, let overlapWindowFrame = element.base.windowFrame else { return false }
        return windowFrame.intersects(overlapWindowFrame)
    }
    
    init?(view: UIView, depth: Int) {
        let base = Base(view, depth: depth)
        if let view = view as? UILabel {
            self = QAElement.label(font: view.font,
                                   maxLines: view.numberOfLines,
                                   text: view.text ?? "",
                                   minimumScaleFactor: view.minimumScaleFactor,
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
            self = QAElement.image(image: view.image,
                                   imageAccessibilityLabel: view.image?.accessibilityLabel,
                                   base: base)
        } else {
            self = QAElement.other(base: base)
        }
    }

    static func < (lhs: QAElement, rhs: QAElement) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }

    static func == (lhs: QAElement, rhs: QAElement) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }

}

