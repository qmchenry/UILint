//
//  UIFinding.swift
//  UILint
//
//  Created by Quinn McHenry on 5/25/20.
//

import Foundation

struct QAFinding: CustomDebugStringConvertible {
    let message: String
    let severity: UIFindingSeverity
    let element: QAElement
    
    var debugDescription: String {
        "Finding (\(element.base.className)): [\(severity)] \(message)"
    }
}

enum UIFindingSeverity {
    case warning
    case error
}
