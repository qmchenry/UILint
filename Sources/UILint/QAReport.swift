//
//  QAReport.swift
//  
//
//  Created by Quinn McHenry on 6/1/20.
//

import PDFKit
import UIKit

class QAReport {
    
    let elements: [QAElement]
    let findings: [QAFinding]
    let screenshot: UIImage?

    let padding = CGFloat(10)
    let paddingLarge = CGFloat(20)

    var currentY = CGFloat(0)

    public init(elements: [QAElement], findings: [QAFinding], screenshot: UIImage?) {
        self.elements = elements
        self.findings = findings
        self.screenshot = screenshot
    }

    public func makePDF() -> Data {

        let pdfTitle = "UILint Report"
        let pdfMetadata = [
            kCGPDFContextCreator: "UILint",
            kCGPDFContextTitle: pdfTitle,
        ]

        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, pdfMetadata)

        newPage()

        draw(pdfTitle, attributes: h1)
        draw("Screenshot", attributes: h2, x: padding)
        draw(screenshot)

        newPage()
        draw("Findings", attributes: h2, x: padding)
        
        findings.forEach { finding in
            let height = draw(finding, draw: false)
            drawRule()
            if currentY + height > pageSize.height {
                newPage()
                currentY += 50
                draw("Findings (continued)", attributes: h2, x: padding)
                drawRule()
            }
            currentY += 5
            draw(finding)
        }

        newPage()
        draw("Elements", attributes: h2, x: padding)

        elements.sorted().forEach { element in
            let height = draw(element, draw: false)
            if height > 0 {
                drawRule()
                if currentY + height > pageSize.height {
                    newPage()
                    draw("Elements (continued)", attributes: h2, x: padding)
                    drawRule()
                }
                draw(element)
            }
        }
        
        drawRule()

        UIGraphicsEndPDFContext()
        return pdfData as Data
    }
    
    var pageSize: CGSize { UIGraphicsGetPDFContextBounds().size }

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
    
    @discardableResult func draw(_ string: String, attributes: [NSAttributedString.Key : Any], x _x: CGFloat? = nil, width: CGFloat? = nil, updateHeight: Bool = true, draw: Bool = true) -> CGSize {
        let x = _x ?? padding
        let actualWidth = width ?? (pageSize.width - 2 * padding)
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let stringSize = attributedString.boundingRect(with: CGSize(width: actualWidth, height: .greatestFiniteMagnitude), options: drawingOptions, context: nil)
        if draw && stringSize.height + currentY > pageSize.height {
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
    
    @discardableResult func draw(_ image: UIImage?, x _x: CGFloat? = nil, width: CGFloat? = nil, updateHeight: Bool = true, draw: Bool = true) -> CGSize {
        guard let image = image else { return .zero }
        let x = _x ?? padding
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

    @discardableResult func draw(_ finding: QAFinding, draw performDraw: Bool = true) -> CGFloat {
        let severityWidth = CGFloat(60)
        let severityHeight = CGFloat(40)
        let remainingWidth = pageSize.width - 4 * padding - severityWidth
        let messageWidth = remainingWidth * 0.6
        let screenshotWidth = remainingWidth - messageWidth
        
        var x = padding
        
        if performDraw {
            color(severity: finding.severity).set()
            UIRectFill(CGRect(x: x, y: currentY, width: severityWidth, height: severityHeight))
            drawCentered(NSAttributedString(string: finding.severity.rawValue,
                                            attributes: style(severity: finding.severity)),
                                            rect: CGRect(x: x, y: currentY, width: severityWidth, height: 40))
        }
        x += severityWidth + padding
        let size0 = draw(finding.message, attributes: body, x: x, width: messageWidth, updateHeight: false, draw: performDraw)
        x += messageWidth + padding
        let size1 = draw(finding.screenshot, x: x, width: screenshotWidth, updateHeight: false, draw: performDraw)
        let rowHeight = max(severityHeight, size0.height, size1.height)
        if performDraw {
            currentY += rowHeight + padding
        }
        return rowHeight
     }
    
    @discardableResult func draw(_ element: QAElement, draw performDraw: Bool = true) -> CGFloat {
        var x = padding
        switch element {
        case .label(let font, let maxLines, let text, let minimumScaleFactor, let base):
            let size0 = draw("Label: \(font.pointSize)pt", attributes: body, x: x, width: 120, updateHeight: false, draw: performDraw)
            x += 120 + padding
            let size1 = draw("\(font.fontName)", attributes: body, x: x, width: 200, updateHeight: false, draw: performDraw)
            x += 200 + padding
            let size2 = draw("\(element.numberOfLines(text: text, font: font, frame: base.windowFrame)) / \(maxLines) lines", attributes: body, x: x, width: 120, updateHeight: false, draw: performDraw)
            x += 120 + padding
            let size3 = draw("\(minimumScaleFactor)", attributes: body, x: x, width: 80, updateHeight: false, draw: performDraw)
            let rowHeight = max(size0.height, size1.height, size2.height, size3.height)
            if performDraw {
                currentY += rowHeight + padding
            }
            let sizeText = draw(text, attributes: detail, x: 40, draw: performDraw)
            let height = rowHeight + padding + sizeText.height
            return height
        default: break
        }
        return 0
    }
    
    func drawRule(color: UIColor = .gray, height: CGFloat = 1) {
        color.set()
        UIRectFrame(CGRect(x: padding, y: currentY, width: pageSize.width - 2 * padding, height: height))
        currentY += height
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
    
    let detail: [NSAttributedString.Key : Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1),
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
