//
//  QACheck.swift
//  
//
//  Created by Quinn McHenry on 6/7/20.
//

import UIKit

public protocol QACheck {
    init()
    var description: String { get }
    func findings(forElement element: QAElement,
                  elements: [QAElement],
                  windowSize: CGSize,
                  screenshot: UIImage?) -> [QAFinding]
}

public let allChecks: [QACheck.Type] = [
    MinimumTapSizeCheck.self,
    OverlappingTouchBlockCheck.self
]
