//
//  QAReport.swift
//  
//
//  Created by Quinn McHenry on 6/1/20.
//

import PDFKit
import UIKit

struct QAReport {
    
    let elements: [QAElement]
    let findings: [QAFinding]
    let screenshot: UIImage?

    let padding = CGFloat(10)
    let paddingLarge = CGFloat(20)


    public func makePDF() -> Data {

        let pdfTitle = "UILint Report"
        let pdfMetadata = [
            kCGPDFContextCreator: "UILint",
            kCGPDFContextTitle: pdfTitle,
        ]

        var currentY = CGFloat(0)

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, pdfMetadata)
        let pageSize = UIGraphicsGetPDFContextBounds().size

        func newPage() {
            UIGraphicsBeginPDFPage()
            currentY = padding
        }

        func drawCentered(_ string: NSAttributedString, rect: CGRect) {
            let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let stringSize = string.boundingRect(with: rect.size, options: drawingOptions, context: nil)
            string.draw(in: CGRect(x: rect.origin.x + (rect.width - stringSize.width) / 2,
                                   y: rect.origin.y + (rect.height - stringSize.height) / 2,
                                   width: stringSize.width,
                                   height: stringSize.height))
        }
        
        @discardableResult func draw(_ string: String, attributes: [NSAttributedString.Key : Any], x: CGFloat = padding, width: CGFloat? = nil, updateHeight: Bool = true, draw: Bool = true) -> CGSize {
            let actualWidth = width ?? (pageSize.width - 2 * padding)
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let stringSize = attributedString.boundingRect(with: CGSize(width: actualWidth, height: .greatestFiniteMagnitude), options: drawingOptions, context: nil)
            print("'\(string)' \(stringSize) \(attributedString.size())")
            if stringSize.height + currentY > pageSize.height {
                newPage()
            }
            let stringRect = CGRect(x: x, y: currentY, width: actualWidth, height: stringSize.height)
            if draw {
                attributedString.draw(in: stringRect)
                if updateHeight {
                    currentY += stringRect.height + padding
                }
            }
            return stringSize.size
        }
        
        @discardableResult func draw(_ image: UIImage?, x: CGFloat = padding, width: CGFloat? = nil, updateHeight: Bool = true, draw: Bool = true) -> CGSize {
            guard let image = image else { return .zero }
            let actualWidth = width ?? (pageSize.width - x - 2 * padding)
            let scaleW = min(image.size.width, actualWidth) / image.size.width
            let scaleH = min(image.size.height, pageSize.height - currentY - padding) / image.size.height
            let scale = min(scaleW, scaleH)
            let drawRect = CGRect(x: x, y: currentY, width: image.size.width * scale, height: image.size.height * scale)
            if draw {
                image.draw(in: drawRect)
                if updateHeight {
                    currentY += drawRect.height + padding
                }
            }
            return drawRect.size
        }

//        @discardableResult func draw(_ finding: QAFinding, draw performDraw: Bool = true) -> CGFloat {
//        }
        
        @discardableResult func draw(_ element: QAElement, draw performDraw: Bool = true) -> CGFloat {
            var x = padding
            switch element {
            case .label(let font, let maxLines, let text, _):
                let size0 = draw("\(font.pointSize)pt", attributes: body, x: x, width: 60, updateHeight: false, draw: performDraw)
                x += 60 + padding
                let size1 = draw("\(font.fontName)", attributes: body, x: x, width: 200, updateHeight: false, draw: performDraw)
                x += 200 + padding
                let size2 = draw("\(maxLines)", attributes: body, x: x, width: 60, updateHeight: true, draw: performDraw)
                let size3 = draw(text, attributes: body, x: 40, draw: performDraw)
                return max(size0.height, size1.height, size2.height) + size3.height
            default: break
            }
            return 0
        }

        newPage()

        draw(pdfTitle, attributes: h1)
        draw("Screenshot", attributes: h2, x: padding)
        draw(screenshot)

        newPage()
        draw("Findings", attributes: h2, x: padding)

        let severityWidth = CGFloat(60)
        let severityHeight = CGFloat(40)
        let remainingWidth = pageSize.width - 4 * padding - severityWidth
        let messageWidth = remainingWidth * 0.6
        let screenshotWidth = remainingWidth - messageWidth
        
        findings.forEach { finding in
            let size1 = draw(finding.message, attributes: body, x: 0, width: messageWidth, updateHeight: false, draw: false)
            let size2 = draw(finding.screenshot, x: 0, width: screenshotWidth, draw: false)
            let findingHeight = max(size1.height, size2.height, severityHeight)
            
            currentY += 5

            if currentY + findingHeight > pageSize.height {
                newPage()
                draw("Findings (continued)", attributes: h2, x: padding)
            }
            
            var x = padding
            color(severity: finding.severity).set()
            UIRectFill(CGRect(x: x, y: currentY, width: severityWidth, height: severityHeight))
            
            drawCentered(NSAttributedString(string: finding.severity.rawValue,
                                            attributes: style(severity: finding.severity)),
                                            rect: CGRect(x: x, y: currentY, width: severityWidth, height: 40))
            x += severityWidth + padding
            draw(finding.message, attributes: body, x: x, width: messageWidth, updateHeight: false)
            x += messageWidth + padding
            draw(finding.screenshot, x: x, width: screenshotWidth, updateHeight: false)
            currentY += findingHeight + padding
        }

        newPage()
        draw("Elements", attributes: h2, x: padding)

        elements.forEach { element in
            let height = draw(element, draw: false)
            if currentY + height > pageSize.height {
                newPage()
                draw("Elements (continued)", attributes: h2, x: padding)
            }
            draw(element)
        }

        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
    let h1: [NSAttributedString.Key : Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .center
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle),
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let h2: [NSAttributedString.Key : Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1),
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let body: [NSAttributedString.Key : Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.paragraphStyle: style]
    }()
    
    let warning: [NSAttributedString.Key : Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.backgroundColor: UIColor.yellow,
                NSAttributedString.Key.paragraphStyle: style]
    }()
    
    let error: [NSAttributedString.Key : Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.backgroundColor: UIColor.red,
                NSAttributedString.Key.paragraphStyle: style]
    }()
    
    func style(severity: QAFindingSeverity) -> [NSAttributedString.Key : Any] {
        if case QAFindingSeverity.error = severity {
            return error
        }
        return warning
    }

    func color(severity: QAFindingSeverity) -> UIColor {
        if case QAFindingSeverity.error = severity {
            return UIColor.red
        }
        return UIColor.yellow
    }

}
