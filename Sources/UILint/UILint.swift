//
//  UILint.swift
//  UILint
//
//  Created by Quinn McHenry on 5/18/20.
//  Copyright © 2020 Quinn McHenry. All rights reserved.
//

import UIKit

public struct UILint {
    
    let elements: [QAElement]
    let findings: [QAFinding]
    let windowSize: CGSize
    let screenshot: UIImage?

    public init?(view: UIView) {
        var currentDepth = 0
        
        screenshot = UIApplication.shared.makeSnapshot()
        let windowSize = screenshot?.size ?? .zero
        
        guard let grandparent = view.parentViewController()?.view else {
            print("Unable to find parent view controller from view")
            elements = []
            findings = []
            self.windowSize = windowSize
            return
        }
                
        func subviews(_ view: UIView) -> [UIView] {
            if let view = view as? UICollectionView {
                return view.visibleCells
            }
            return view.subviews
        }
        
        func recurse(_ view: UIView) -> [QAElement] {
            let viewOutput = [QAElement(view: view, depth: currentDepth)].compactMap{$0}
            currentDepth += 1
            return subviews(view).compactMap { recurse($0) }.reduce(viewOutput, +)
        }
        
        let elements = recurse(grandparent)
        findings = elements.flatMap { $0.findings(elements: elements, windowSize: windowSize) }
        self.elements = elements
        self.windowSize = windowSize
    }
    
}
