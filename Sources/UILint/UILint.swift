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
        
        elements = recurse(grandparent)
    }
    
    var findings: [QAFinding] {
        elements.flatMap { $0.findings(elements: elements, windowSize: windowSize, screenshot: screenshot) }
    }

    public func makePDF() -> Data {
        let pdf = SimplePDF(pageSize: CGSize(width: 850, height: 1100))
        
        if let screenshot = screenshot {
            pdf.beginHorizontalArrangement()
            pdf.addImage(screenshot)
            // pdf.addText("app/view details")
            pdf.endHorizontalArrangement()
            pdf.beginNewPage()
        }

        pdf.addLineSeparator(height: 0.1)

        findings.forEach { finding in
            pdf.addVerticalSpace(10)
            pdf.beginHorizontalArrangement()
            pdf.addText(finding.severity.rawValue)
            pdf.addHorizontalSpace(10)
            pdf.addText(finding.message)
            if let croppedScreenshot = finding.screenshot {
                pdf.setContentAlignment(.right)
                pdf.addImage(croppedScreenshot)
                pdf.setContentAlignment(.left)
            }
            pdf.endHorizontalArrangement()
            pdf.addVerticalSpace(10)
            pdf.addLineSeparator(height: 0.1)
        }
        
        let pdfData = pdf.generatePDFdata()
        try? pdfData.write(to: URL(fileURLWithPath: "/tmp/test.pdf"), options: Data.WritingOptions.atomic)
        return pdfData
    }
}

