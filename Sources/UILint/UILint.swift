//
//  UILint.swift
//  UILint
//
//  Created by Quinn McHenry on 5/18/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

import UIKit
import SimplePDF

public struct UILint {
    
    let elements: [QAElement]
    let windowSize: CGSize
    let screenshot: UIImage?

    public init?(view: UIView) {
        guard let grandparent = view.parentViewController()?.view else {
            print("Unable to find parent view controller from view")
            return nil
        }
        
        var currentDepth = 0
                
        screenshot = grandparent.makeSnapshot()
        windowSize = screenshot?.size ?? .zero
        
        func recurse(_ view: UIView) -> [QAElement] {
            let viewOutput = [QAElement(view: view, depth: currentDepth)].compactMap{$0}
            currentDepth += 1
            return view.allSubviews.compactMap { recurse($0) }.reduce(viewOutput, +)
        }
        
        elements = recurse(grandparent)
    }
    
    var findings: [QAFinding] {
        elements.flatMap { $0.findings(elements: elements, windowSize: windowSize, screenshot: screenshot) }
    }

    public func makePDF() -> Data {
        QAReport().makePDF(elements: elements, findings: findings, screenshot: screenshot)
    }
    
}

