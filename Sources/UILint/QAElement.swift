//
//  QAElement.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

public enum QAElement: Comparable {

    case label(font: UIFont, maxLines: Int, text: String, textColor: UIColor, base: Base)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, base: Base)
    case image(image: UIImage?, imageAccessibilityLabel: String?, base: Base)
    case other(base: Base)

    public struct Base {
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

        allChecks.forEach { check in
            results += check.init()
                .findings(forElement: self, elements: elements, windowSize: windowSize, screenshot: screenshot)
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
                                   textColor: view.textColor,
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

    public static func < (lhs: QAElement, rhs: QAElement) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }

    public static func == (lhs: QAElement, rhs: QAElement) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }

}
