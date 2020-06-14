//
//  QAElement.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

public enum Element: Comparable, CustomDebugStringConvertible {

    case label(font: UIFont, maxLines: Int, text: String, textColor: UIColor, base: Base)
    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, base: Base)
    case image(image: UIImage?, imageAccessibilityLabel: String?, base: Base)
    case other(base: Base)

    public struct Base {
        public let className: String
        public let windowFrame: CGRect?
        public let wantsTouches: Bool // like a button
        public let consumesTouches: Bool // opaque view that blocks
        public let depth: Int
        public let level: Int
        public let contentScaleFactor: CGFloat
        public let contentMode: UIView.ContentMode
        public let accessibilityIdentifier: String?
        public let tag: Int
        init(_ view: UIView, depth: Int, level: Int) {
            self.className = view.className
            self.windowFrame = view.windowFrame
            let enabledGestureRecognizers = view.gestureRecognizers?.filter { $0.isEnabled }.count ?? 0
            wantsTouches = (view is UIControl) || enabledGestureRecognizers > 0
            consumesTouches = view.consumesTouches
            self.depth = depth
            self.level = level
            contentScaleFactor = view.contentScaleFactor
            contentMode = view.contentMode
            accessibilityIdentifier = view.accessibilityIdentifier
            tag = view.tag
        }
    }

    public var base: Base {
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
    var isButton: Bool { sortOrder == 200 }
    var isImage: Bool { sortOrder == 300 }

    func findings(elements: [Element], context: LintingContext) -> [Finding] {
        var results = [Finding]()
        let enabledChecks = allChecks.filter { check in
            !UILintConfig.shared.excludedChecks.contains { $0 == check }
        }
        enabledChecks.forEach { check in
            if context.shouldLint?(self, check) ?? true {
                results += check.init()
                    .findings(forElement: self, elements: elements, context: context)
            } else { print("Skipping check \(check.self) on \(self)") }
        }
        return results
    }

    func overlaps(_ element: Element) -> Bool {
        guard let windowFrame = base.windowFrame, let overlapWindowFrame = element.base.windowFrame else {
            return false
        }
        return windowFrame.intersects(overlapWindowFrame)
    }

    public var debugDescription: String {
        let descriptions: [String?] = [
                base.className,
                base.tag != 0 ? "tag:\(base.tag)" : nil,
                base.accessibilityIdentifier != nil ?  "aid:'\(base.accessibilityIdentifier!)'" : nil
            ]
        return descriptions.compactMap { $0 }.joined(separator: " ")
    }

    init?(view: UIView, depth: Int, level: Int) {
        let base = Base(view, depth: depth, level: level)
        if let view = view as? UILabel {
            self = Element.label(font: view.font,
                                   maxLines: view.numberOfLines,
                                   text: view.text ?? "",
                                   textColor: view.textColor,
                                   base: base)
        } else if let view = view as? UIButton {
            let font = view.titleLabel?.font
            self = Element.button(fontName: font?.fontName,
                                    fontSize: font?.pointSize,
                                    title: view.titleLabel?.text,
                                    hasImage: view.imageView?.image != nil,
                                    base: base)
        } else if let view = view as? UIImageView {
            self = Element.image(image: view.image,
                                   imageAccessibilityLabel: view.image?.accessibilityLabel,
                                   base: base)
        } else {
            self = Element.other(base: base)
        }
    }

    public static func < (lhs: Element, rhs: Element) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }

    public static func == (lhs: Element, rhs: Element) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
}
