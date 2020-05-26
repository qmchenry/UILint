//
//  UIFinding.swift
//  UILint
//
//  Created by Quinn McHenry on 5/25/20.
//

import Foundation

struct QAFinding {
    let message: String
    let severity: UIFindingSeverity
    let element: QAElement
}

enum UIFindingSeverity {
    case warning
    case error
}
