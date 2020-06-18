//
//  UILabelChecks.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension Element {

    var labelText: String? {
        guard isLabel, case let Element.label(_, _, text, _, _) = self else { return nil }
        return text
    }

    func isLabelTruncated() -> Bool {
        guard isLabel, case let Element.label(font, maxLines, text, _, base) = self,
            let frame = base.windowFrame else { return false }
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return maxLines > 0 ? numberOfLines(text: text, font: font, frame: frame) > maxLines : false
    }

    func isLabelClippedVertically() -> Bool {
        guard isLabel, case let Element.label(_, _, text, _, base) = self,
            let frame = base.windowFrame else { return false }
        guard text.count > 0 else { return false }
        guard frame.width > 0 else { return true }
        return labelSize().height > frame.size.height
    }

    func isLabelOffscreen(windowSize: CGSize) -> Bool {
        guard isLabel, case let Element.label(_, _, _, _, base) = self,
            let frame = base.windowFrame else { return false }
        let windowRect = CGRect(origin: .zero, size: windowSize)
        return windowRect.union(frame) != windowRect
    }

    func numberOfLines(text: String, font: UIFont, frame: CGRect?) -> Int {
        guard isLabel, frame != nil, text.count > 0 else { return 0 }
        let size = labelSize()
        return Int(ceil(size.height) / font.lineHeight)
    }

    func labelSize() -> CGSize {
        guard isLabel, case let Element.label(font, _, text, _, base) = self,
            let frame = base.windowFrame else { return .zero }
        return (text as NSString).boundingRect(with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size
    }
}
