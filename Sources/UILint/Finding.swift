//
//  UIFinding.swift
//  UILint
//
//  Created by Quinn McHenry on 5/25/20.
//

import UIKit

public struct Finding: CustomDebugStringConvertible {
    let description: String
    let explanation: String
    let severity: QAFindingSeverity
    let screenshot: UIImage?
    let element: Element

    public var debugDescription: String {
        "Finding (\(element.base.className)): [\(severity)] \(description) \(explanation)"
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
