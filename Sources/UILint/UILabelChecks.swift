//
//  UILabelChecks.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension QAElement {
    func isLabelTruncated(text: String, font: UIFont, frame: CGRect) -> Bool {
        let size = labelSize(text: text, font: font, frame: frame)
        return size.height > frame.size.height
    }
    
    func numberOfLines(text: String, font: UIFont, frame: CGRect) -> Int {
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
