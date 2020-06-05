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
}
