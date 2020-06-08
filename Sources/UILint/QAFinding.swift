//
//  UIFinding.swift
//  UILint
//
//  Created by Quinn McHenry on 5/25/20.
//

import UIKit

public struct QAFinding: CustomDebugStringConvertible {
    let message: String
    let severity: QAFindingSeverity
    let screenshot: UIImage?
    let element: QAElement

    public var debugDescription: String {
        "Finding (\(element.base.className)): [\(severity)] \(message)"
    }
}

public enum QAFindingSeverity: String {
    case warning
    case error

    var textColor: UIColor {
        switch self {
        case .warning: return .blue
        case .error: return .red
        }
    }
}
