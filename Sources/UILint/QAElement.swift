//
//  QAElement.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

enum QAElement: Comparable {

    case label(font: UIFont, maxLines: Int, text: String, minimumScaleFactor: CGFloat, base: Base)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, base: Base)
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
        case .button(_, _, _, _, let base): return base
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
        case .label:
            results += labelChecks(windowSize: windowSize, screenshot: screenshot, elements: elements)
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
                    let cropped = screenshot?.crop(to: unionBounds, viewSize: screenshot!.size)
                    let message = "Tappable view \(base.className) is obscured by \(element.base.className)"
                    let finding = QAFinding(message: message, severity: .error,
                                            screenshot: cropped, element: self)
                    results.append(finding)
                }
            }

            // Minimum tappable size
            if windowFrame.size.height < 44 || windowFrame.size.width < 44 {
                let cropped = screenshot?.crop(to: windowFrame, viewSize: screenshot!.size)
                let message = "Provide ample touch targets for interactive elements. \(base.className) width/height is "
                              + "less than 44pt (\(windowFrame.width),\(windowFrame.height))"
                let finding = QAFinding(message: message, severity: .error, screenshot: cropped, element: self)
                results.append(finding)
            }
        }

        return results
    }

    func overlaps(_ element: QAElement) -> Bool {
        guard let windowFrame = base.windowFrame, let overlapWindowFrame = element.base.windowFrame else {
            return false
        }
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
