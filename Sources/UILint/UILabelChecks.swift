//
//  UILabelChecks.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension Element {

    var labelText: String? {
        guard isLabel, case let Element.label(_, _, text, _, _, _, _) = self else { return nil }
        return text
    }

    func isLabelTruncated() -> Bool {
        guard isLabel, case let Element.label(font, maxLines, text, _, _, _, base) = self,
            let frame = base.windowFrame else { return false }
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return maxLines > 0 ? numberOfLines(text: text, font: font, frame: frame) > maxLines : false
    }

    func isLabelClippedVertically() -> Bool {
        guard isLabel, case let Element.label(_, _, text, _, _, _, base) = self,
            let frame = base.windowFrame else { return false }
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return labelSize().height.rounded() > frame.size.height.rounded()
    }

    func isLabelOffscreen(windowSize: CGSize) -> Bool {
        guard isLabel, case let Element.label(_, _, _, _, _, _, base) = self,
            let frame = base.windowFrame else { return false }
        let windowRect = CGRect(origin: .zero, size: windowSize).rounded
        return windowRect.union(frame) != windowRect
    }

    func numberOfLines(text: String, font: UIFont, frame: CGRect?) -> Int {
        guard isLabel, frame != nil, text.count > 0 else { return 0 }
        let size = labelSize()
        return Int(ceil(size.height) / font.lineHeight)
    }

    func labelSize() -> CGSize {
        guard isLabel, case let Element.label(font, _, text, _, _, _, base) = self,
            let frame = base.windowFrame else { return .zero }
        return (text as NSString).boundingRect(with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
    }
}

class LabelColorExtractor {
    var renderer: UIGraphicsImageRenderer!
    var screenshot: UIImage
    var label: UILabel {
        didSet {
            renderer = UIGraphicsImageRenderer(size: rect.size)
        }
    }
    var rect: CGRect {
        let scale = label.layer.contentsScale
        let scaledRect = CGRect(x: 0, y: 0, width: label.frame.width/scale, height: label.frame.height/scale)
        return scaledRect
    }

    init?(screenshot: UIImage?, label: UILabel) {
        guard let screenshot = screenshot else { return nil }
        self.screenshot = screenshot
        self.label = label
        let scale = label.layer.contentsScale
        let scaledSize = CGSize(width: label.frame.width/scale, height: label.frame.height/scale)
        renderer = UIGraphicsImageRenderer(size: scaledSize)
    }

    var backgroundColor: UIColor? {
        let backgroundOnly = renderer.image { context in
            screenshot.draw(in: rect)
            context.cgContext.setBlendMode(.clear)
            context.cgContext.setFontSize(label.font.pointSize)
            label.layer.draw(in: context.cgContext)
        }
        let bgColor = backgroundOnly.averageColor(rect: rect)
        return bgColor
    }

    var textColor: UIColor? {
        let textOnly = renderer.image { _ in
            label.drawText(in: rect)
        }
        let textColor = textOnly.averageColor(rect: rect)
        return textColor
    }
}
