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
        
        let h1 = UIFont.systemFont(ofSize: 24, weight: .heavy)
        let h2 = UIFont.systemFont(ofSize: 18, weight: .heavy)
        let h3 = UIFont.systemFont(ofSize: 12, weight: .bold)
        let body = UIFont.systemFont(ofSize: 12, weight: .regular)

        if let screenshot = screenshot {
            pdf.beginHorizontalArrangement()
            pdf.addImage(screenshot)
            // pdf.addText("app/view details")
            pdf.endHorizontalArrangement()
            pdf.beginNewPage()
        }

        pdf.addText("Findings", font: h1, textColor: .black)

        pdf.addVerticalSpace(20)
        pdf.addLineSeparator(height: 0.1)

        findings.forEach { finding in
            pdf.addVerticalSpace(10)
            pdf.beginHorizontalArrangement()
            pdf.addText(finding.severity.rawValue, font: h3, textColor: finding.severity.textColor)
            pdf.addHorizontalSpace(10)
            pdf.addText(finding.message, font: body)
            if let croppedScreenshot = finding.screenshot {
                pdf.setContentAlignment(.right)
                pdf.addImage(croppedScreenshot)
                pdf.setContentAlignment(.left)
            }
            pdf.endHorizontalArrangement()
            pdf.addVerticalSpace(10)
            pdf.addLineSeparator(height: 0.1)
        }
        
        pdf.beginNewPage()

        pdf.addText("Elements", font: h1, textColor: .black)

        pdf.addVerticalSpace(20)
        
        pdf.addText("Labels", font: h2, textColor: .black)
        pdf.addVerticalSpace(10)

        pdf.addLineSeparator(height: 0.1)
        
        elements.forEach { element in
            switch element {
            case .label(let font, let maxLines, let text, _):
                pdf.addVerticalSpace(10)
                pdf.addText("\(font.pointSize)pt \(font.fontName), maxLines=\(maxLines)", font: h3)
                pdf.addText(text, font: body)
                pdf.addVerticalSpace(10)
                pdf.addLineSeparator(height: 0.1)
            default: break
            }
        }

        
        return pdf.generatePDFdata()
    }
}

