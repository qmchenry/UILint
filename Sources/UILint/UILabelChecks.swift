//
//  UILabelChecks.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension QAElement {
    func isLabelTruncated(text: String, font: UIFont, maxLines: Int, frame: CGRect) -> Bool {
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return maxLines > 0 ? numberOfLines(text: text, font: font, frame: frame) > maxLines : false
    }

    func isLabelClippedVertically(text: String, font: UIFont, frame: CGRect) -> Bool {
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return labelSize(text: text, font: font, frame: frame).height > frame.size.height
    }

    func isLabelOffscreen(labelFrame: CGRect, windowSize: CGSize) -> Bool {
        let windowRect = CGRect(origin: .zero, size: windowSize)
        return windowRect.union(labelFrame) != windowRect
    }

    func numberOfLines(text: String, font: UIFont, frame: CGRect?) -> Int {
        guard let frame = frame, text.count > 0 else { return 0 }
        let size = labelSize(text: text, font: font, frame: frame)
        return Int(ceil(size.height) / font.lineHeight)
    }

    func labelSize(text: String, font: UIFont, frame: CGRect) -> CGSize {
        (text as NSString).boundingRect(with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
    }

    func labelChecks(windowSize: CGSize,
                     screenshot: UIImage?,
                     elements: [QAElement]) -> [QAFinding] {
        guard case let QAElement.label(font, maxLines, text, _, base) = self,
            let windowFrame = base.windowFrame else { return [] }
        var results = [QAFinding]()

        let croppedScreenshot = screenshot?.crop(to: windowFrame, viewSize: screenshot!.size)

        if isLabelTruncated(text: text, font: font, maxLines: maxLines, frame: windowFrame) {
            results.append(QAFinding(message: "Label is truncated", severity: .error,
                                     screenshot: croppedScreenshot, element: self))
        }

        if isLabelClippedVertically(text: text, font: font, frame: windowFrame) {
            results.append(QAFinding(message: "Label is clipped vertically", severity: .error,
                                     screenshot: croppedScreenshot, element: self))
        }

        if windowSize != .zero && isLabelOffscreen(labelFrame: windowFrame, windowSize: windowSize) {
            results.append(QAFinding(message: "Label is (partially) offscreen", severity: .error,
                                     screenshot: croppedScreenshot, element: self))
        }

        if !QAConfig.expectedFontNames.isEmpty && !QAConfig.expectedFontNames.contains(font.fontName) {
            results.append(QAFinding(message: "Label uses unexpected font \(font.fontName)", severity: .error,
                                     screenshot: croppedScreenshot, element: self))
        }

        elements.filter { $0.isLabel && $0.depth > depth }.forEach { element in
            // considering only depths > self's depth prevents duplication of findings as they both
            // overlap each other and also checking against self
            if overlaps(element) {
                let unionBounds = windowFrame.union(element.base.windowFrame!)
                let croppedScreenshot = screenshot?.crop(to: unionBounds, viewSize: screenshot!.size)
                results.append(QAFinding(message: "\(base.className) overlaps \(element.base.className)",
                    severity: .warning, screenshot: croppedScreenshot, element: self))
            }
        }
        return results
    }
}
