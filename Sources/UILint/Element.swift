//
//  QAElement.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

public protocol Element: Comparable, CustomDebugStringConvertible {
    var base: ElementBase { get }
    var isLabel: Bool { get }
    var isSafeAreaAware: Bool { get }
    var sortOrder: Float { get }
//    func findings(elements: Array<Self>, context: LintingContext) -> [Finding]
}

public struct ElementBase {
    public let className: String
    public let windowFrame: CGRect?
    public let backgroundColor: UIColor?
    public let effectiveBackgroundColor: CGColor?
    public let wantsTouches: Bool // like a button
    public let consumesTouches: Bool // opaque view that blocks
    public let depth: Int
    public let level: Int
    public let contentScaleFactor: CGFloat
    public let contentMode: UIView.ContentMode
    public let accessibilityIdentifier: String?
    public let tag: Int
    init(_ view: UIView, depth: Int, level: Int, context: LintingContext) {
        let screenshot = context.screenshot?.crop(to: view.windowFrame, viewSize: context.screenshot?.size)
        className = view.className
        windowFrame = view.windowFrame
        backgroundColor = view.backgroundColor
        effectiveBackgroundColor = screenshot?.effectiveBackgroundColor()
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

extension Element {

//    public func findings(elements: Array<Self>, context: LintingContext) -> [Finding] {
//        var results = [Finding]()
//        let enabledChecks = allChecks.filter { check in
//            !UILintConfig.shared.excludedChecks.contains { $0 == check }
//        }
//        enabledChecks.forEach { check in
//            if context.shouldLint?(self, check) ?? true {
//                results += check.init()
//                    .findings(forElement: self, elements: elements, context: context)
//            } else { print("Skipping check \(check.self) on \(self)") }
//        }
//        return results
//    }
//
    public func overlaps<T: Element>(_ element: T) -> Bool {
        guard let windowFrame = base.windowFrame, let overlapWindowFrame = element.base.windowFrame else {
            return false
        }
        return windowFrame.intersects(overlapWindowFrame)
    }
}

extension Element {
    public static func < <T: Element>(lhs: Self, rhs: T) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }

    public static func == <T: Element>(lhs: Self, rhs: T) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
}

public struct Label: Element {
    public let isLabel = true
    public let sortOrder = Float(100)
    public let isSafeAreaAware = true

    let font: UIFont
    let maxLines: Int
    let text: String
    let textColor: UIColor
    let measuredTextColor: UIColor?
    let measuredBackgroundColor: UIColor?
    public let base: ElementBase

    public var debugDescription: String {
        let descriptions: [String?] = [
                base.className,
                base.tag != 0 ? "tag:\(base.tag)" : nil,
                base.accessibilityIdentifier != nil ?  "aid:'\(base.accessibilityIdentifier!)'" : nil
            ]
        return descriptions.compactMap { $0 }.joined(separator: " ")
    }
}

public struct Button: Element {
    public let isLabel = true
    public let sortOrder = Float(200)
    public let isSafeAreaAware = true

    let fontName: String?
    let fontSize: CGFloat?
    let title: String?
    let hasImage: Bool
    public let base: ElementBase

    public var debugDescription: String {
        let descriptions: [String?] = [
                base.className,
                base.tag != 0 ? "tag:\(base.tag)" : nil,
                base.accessibilityIdentifier != nil ?  "aid:'\(base.accessibilityIdentifier!)'" : nil
            ]
        return descriptions.compactMap { $0 }.joined(separator: " ")
    }
}

public struct Image: Element {
    public let isLabel = false
    public let sortOrder = Float(300)
    public let isSafeAreaAware = true
    public let base: ElementBase

    let image: UIImage?
    let imageAccessibilityLabel: String?

    public var debugDescription: String {
        let descriptions: [String?] = [
                base.className,
                base.tag != 0 ? "tag:\(base.tag)" : nil,
                base.accessibilityIdentifier != nil ?  "aid:'\(base.accessibilityIdentifier!)'" : nil
            ]
        return descriptions.compactMap { $0 }.joined(separator: " ")
    }
}

//public enum ElementX { //: Comparable, CustomDebugStringConvertible {
//
//    case label(font: UIFont, maxLines: Int, text: String, textColor: UIColor,
//        measuredTextColor: UIColor?, measuredBackgroundColor: UIColor?, base: Base)
//    case button(fontName: String?, fontSize: CGFloat?, title: String?, hasImage: Bool, base: Base)
//    case image(image: UIImage?, imageAccessibilityLabel: String?, base: Base)
//    case other(base: Base)
//
//    public struct Base {
//        public let className: String
//        public let windowFrame: CGRect?
//        public let backgroundColor: UIColor?
//        public let effectiveBackgroundColor: CGColor?
//        public let wantsTouches: Bool // like a button
//        public let consumesTouches: Bool // opaque view that blocks
//        public let depth: Int
//        public let level: Int
//        public let contentScaleFactor: CGFloat
//        public let contentMode: UIView.ContentMode
//        public let accessibilityIdentifier: String?
//        public let tag: Int
//        init(_ view: UIView, depth: Int, level: Int, context: LintingContext) {
//            let screenshot = context.screenshot?.crop(to: view.windowFrame, viewSize: context.screenshot?.size)
//            className = view.className
//            windowFrame = view.windowFrame
//            backgroundColor = view.backgroundColor
//            effectiveBackgroundColor = screenshot?.effectiveBackgroundColor()
//            let enabledGestureRecognizers = view.gestureRecognizers?.filter { $0.isEnabled }.count ?? 0
//            wantsTouches = (view is UIControl) || enabledGestureRecognizers > 0
//            consumesTouches = view.consumesTouches
//            self.depth = depth
//            self.level = level
//            contentScaleFactor = view.contentScaleFactor
//            contentMode = view.contentMode
//            accessibilityIdentifier = view.accessibilityIdentifier
//            tag = view.tag
//        }
//    }
//
//    public var base: Base {
//        switch self {
//        case .label(_, _, _, _, _, _, let base): return base
//        case .button(_, _, _, _, let base): return base
//        case .image(_, _, let base): return base
//        case .other(let base): return base
//        }
//    }
//
//    var depth: Int {
//        return base.depth
//    }
//
//    var sortOrder: Int {
//        switch self {
//        case .label: return 100
//        case .button: return 200
//        case .image: return 300
//        case .other: return 10000
//        }
//    }
//
//    var isLabel: Bool { sortOrder == 100 }
//    var isButton: Bool { sortOrder == 200 }
//    var isImage: Bool { sortOrder == 300 }

//    func findings(elements: [Element], context: LintingContext) -> [Finding] {
//        var results = [Finding]()
//        let enabledChecks = allChecks.filter { check in
//            !UILintConfig.shared.excludedChecks.contains { $0 == check }
//        }
//        enabledChecks.forEach { check in
//            if context.shouldLint?(self, check) ?? true {
//                results += check.init()
//                    .findings(forElement: self, elements: elements, context: context)
//            } else { print("Skipping check \(check.self) on \(self)") }
//        }
//        return results
//    }

//    func overlaps<T: Element>(_ element: T) -> Bool {
//        guard let windowFrame = base.windowFrame, let overlapWindowFrame = element.base.windowFrame else {
//            return false
//        }
//        return windowFrame.intersects(overlapWindowFrame)
//    }
//
//    public var debugDescription: String {
//        let descriptions: [String?] = [
//                base.className,
//                base.tag != 0 ? "tag:\(base.tag)" : nil,
//                base.accessibilityIdentifier != nil ?  "aid:'\(base.accessibilityIdentifier!)'" : nil
//            ]
//        return descriptions.compactMap { $0 }.joined(separator: " ")
//    }

//    init?(view: UIView, depth: Int, level: Int, context: LintingContext) {
//        let base = Base(view, depth: depth, level: level, context: context)
//        if let view = view as? UILabel {
//            let texture = context.screenshot?.crop(to: view.windowFrame, viewSize: context.screenshot!.size)
//            let extractor = LabelColorExtractor(screenshot: texture, label: view)
//            self = Element.label(font: view.font,
//                                   maxLines: view.numberOfLines,
//                                   text: view.text ?? "",
//                                   textColor: view.textColor,
//                                   measuredTextColor: extractor?.textColor,
//                                   measuredBackgroundColor: extractor?.backgroundColor,
//                                   base: base)
//        } else if let view = view as? UIButton {
//            let font = view.titleLabel?.font
//            self = Element.button(fontName: font?.fontName,
//                                    fontSize: font?.pointSize,
//                                    title: view.titleLabel?.text,
//                                    hasImage: view.imageView?.image != nil,
//                                    base: base)
//        } else if let view = view as? UIImageView {
//            self = Element.image(image: view.image,
//                                   imageAccessibilityLabel: view.image?.accessibilityLabel,
//                                   base: base)
//        } else {
//            self = Element.other(base: base)
//        }
//    }
//
//    public static func < (lhs: Element, rhs: Element) -> Bool {
//        return lhs.sortOrder < rhs.sortOrder
//    }
//
//    public static func == (lhs: Element, rhs: Element) -> Bool {
//        return lhs.sortOrder == rhs.sortOrder
//    }
//}
