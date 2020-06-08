//
//  UILabelChecks.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension QAElement {

    var labelText: String? {
        guard case let QAElement.label(_, _, text, _, _) = self else { return nil }
        return text
    }

    func isLabelTruncated() -> Bool {
        guard case let QAElement.label(font, maxLines, text, _, base) = self,
            let frame = base.windowFrame else { return false }
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return maxLines > 0 ? numberOfLines(text: text, font: font, frame: frame) > maxLines : false
    }

    func isLabelClippedVertically() -> Bool {
        guard case let QAElement.label(_, _, text, _, base) = self,
            let frame = base.windowFrame else { return false }
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return labelSize().height > frame.size.height
    }

    func isLabelOffscreen(labelFrame: CGRect, windowSize: CGSize) -> Bool {
        let windowRect = CGRect(origin: .zero, size: windowSize)
        return windowRect.union(labelFrame) != windowRect
    }

    func numberOfLines(text: String, font: UIFont, frame: CGRect?) -> Int {
        guard let _ = frame, text.count > 0 else { return 0 }
        let size = labelSize()
        return Int(ceil(size.height) / font.lineHeight)
    }

    func labelSize() -> CGSize {
        guard case let QAElement.label(font, _, text, _, base) = self,
            let frame = base.windowFrame else { return .zero }
        return (text as NSString).boundingRect(with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
    }

    func labelChecks(windowSize: CGSize,
                     screenshot: UIImage?,
                     elements: [QAElement]) -> [QAFinding] {
        guard case let QAElement.label(font, _, _, _, base) = self,
            let windowFrame = base.windowFrame else { return [] }
        var results = [QAFinding]()

        let croppedScreenshot = screenshot?.crop(to: windowFrame, viewSize: screenshot!.size)

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
