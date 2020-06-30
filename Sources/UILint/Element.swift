//
//  QAElement.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

public class Element: CustomDebugStringConvertible {
    public var isLabel: Bool { false }
    public var sortOrder: Float { 100 }
    public var isSafeAreaAware: Bool { false }

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

    public var debugDescription: String {
        let descriptions: [String?] = [
                className,
                tag != 0 ? "tag:\(tag)" : nil,
                accessibilityIdentifier != nil ?  "aid:'\(accessibilityIdentifier!)'" : nil
            ]
        return descriptions.compactMap { $0 }.joined(separator: " ")
    }
}

extension Element {

    public func findings(elements: [Element], context: LintingContext) -> [Finding] {
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

    public func overlaps(_ element: Element) -> Bool {
        guard let windowFrame = windowFrame, let overlapWindowFrame = element.windowFrame else {
            return false
        }
        return windowFrame.intersects(overlapWindowFrame)
    }
}

extension Element: Comparable {
    public static func < (lhs: Element, rhs: Element) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }

    public static func == (lhs: Element, rhs: Element) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
}

public class Label: Element {
    public override var isLabel: Bool { true }
    public override var sortOrder: Float { 200 }
    public override var isSafeAreaAware: Bool { true }

    let font: UIFont
    let maxLines: Int
    let text: String
    let textColor: UIColor
    let measuredTextColor: UIColor?
    let measuredBackgroundColor: UIColor?

    init(_ view: UILabel, depth: Int, level: Int, context: LintingContext) {
        let texture = context.screenshot?.crop(to: view.windowFrame, viewSize: context.screenshot!.size)
        let extractor = LabelColorExtractor(screenshot: texture, label: view)
        font = view.font
        maxLines = view.numberOfLines
        text = view.text ?? ""
        textColor = view.textColor
        measuredTextColor = extractor?.textColor
        measuredBackgroundColor = extractor?.backgroundColor
        super.init(view, depth: depth, level: level, context: context)
    }
}

public class Button: Element {
    public override var sortOrder: Float { 300 }
    public override var isSafeAreaAware: Bool { true }

    let fontName: String?
    let fontSize: CGFloat?
    let title: String?
    let hasImage: Bool

    init(_ view: UIButton, depth: Int, level: Int, context: LintingContext) {
        fontName = view.titleLabel?.font.fontName
        fontSize = view.titleLabel?.font.pointSize
        title = view.titleLabel?.text
        hasImage = view.imageView?.image != nil
        super.init(view, depth: depth, level: level, context: context)
    }
}

public class Image: Element {
    public override var sortOrder: Float { 400 }

    let image: UIImage?
    let imageAccessibilityLabel: String?

    init(_ view: UIImageView, depth: Int, level: Int, context: LintingContext) {
        image = view.image
        imageAccessibilityLabel = view.image?.accessibilityLabel
        super.init(view, depth: depth, level: level, context: context)
    }
}
