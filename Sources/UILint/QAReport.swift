//
//  QAReport.swift
//  
//
//  Created by Quinn McHenry on 6/1/20.
//

import SimplePDF
import UIKit

struct QAReport {
        
    public func makePDF(elements: [QAElement], findings: [QAFinding], screenshot: UIImage?) -> Data {
        let pdf = SimplePDF(pageSize: CGSize(width: 850, height: 1100))
        
        let h1 = UIFont.systemFont(ofSize: 24, weight: .heavy)
        let h2 = UIFont.systemFont(ofSize: 18, weight: .heavy)
        let h3 = UIFont.systemFont(ofSize: 12, weight: .bold)
        let body = UIFont.systemFont(ofSize: 12, weight: .regular)

        pdf.addText("UILint Report", font: h1)
        pdf.addVerticalSpace(10)
        pdf.addText("Generated at \(Date())", font: h3)
        pdf.addVerticalSpace(20)

        if let screenshot = screenshot {
            pdf.addText("Full screenshot", font: h2)
            pdf.addVerticalSpace(20)
            pdf.addImage(screenshot)
            pdf.beginNewPage()
        }

        pdf.addText("Findings", font: h1, textColor: .black)

        pdf.addVerticalSpace(15)
        pdf.addLineSeparator(height: 0.1)

        findings.forEach { finding in
            pdf.addVerticalSpace(5)
            pdf.beginHorizontalArrangement()
            pdf.addText(finding.severity.rawValue, font: h3, textColor: finding.severity.textColor)
            pdf.addHorizontalSpace(10)
            pdf.addText(finding.message, font: body)
            pdf.endHorizontalArrangement()
            if let croppedScreenshot = finding.screenshot {
                pdf.setContentAlignment(.right)
                pdf.addImage(croppedScreenshot)
                pdf.setContentAlignment(.left)
            }
            pdf.addVerticalSpace(5)
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
