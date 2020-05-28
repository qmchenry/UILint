//
//  UIFinding.swift
//  UILint
//
//  Created by Quinn McHenry on 5/25/20.
//

import UIKit

struct QAFinding: CustomDebugStringConvertible {
    let message: String
    let severity: UIFindingSeverity
    let screenshot: UIImage?
    let element: QAElement
    
    var debugDescription: String {
        "Finding (\(element.base.className)): [\(severity)] \(message)"
    }
}

enum UIFindingSeverity: String {
    case warning
    case error
}
