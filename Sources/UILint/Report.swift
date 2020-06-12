//
//  QAReport.swift
//
//
//  Created by Quinn McHenry on 6/1/20.
//

import PDFKit
import UIKit

class Report {

    let elements: [Element]
    let findings: [Finding]
    let details: LintingContext

    let pdfTitle = "UILint Report"
    let padding = CGFloat(10)
    let paddingLarge = CGFloat(20)

    var currentY = CGFloat(0)
    var screenshot: UIImage? { details.screenshot }

    public init(elements: [Element], findings: [Finding], details: LintingContext ) {
        self.elements = elements
        self.findings = findings
        self.details = details
    }

    var pdfMetadata: [AnyHashable: Any] {
        [
            kCGPDFContextCreator: "UILint",
            kCGPDFContextTitle: pdfTitle
        ]
    }

    public func makePDF() -> Data {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, pdfMetadata)
        drawFirstPage()
        newPage("Findings")
        if findings.isEmpty {
            draw("No findings", attributes: body)
        }
        findings.forEach { finding in
            let height = draw(finding, draw: false)
            drawRule()
            if currentY + height + 5 > pageSize.height {
                newPage("Findings (continued)")
            }
            currentY += 5
            draw(finding)
        }

        newPage("Elements")
        elements.sorted().forEach { element in
            let height = draw(element, draw: false)
            if height > 0 {
                if currentY + height + 5 > pageSize.height {
                    newPage("Elements (continued)")
                }
                currentY += 5
                draw(element)
            }
        }

        newPage("View Hierarchy")
        currentY += 5
        elements.forEach { element in
            let height = draw(heirarchyElement: element, draw: false)
            if currentY + height + 5 > pageSize.height {
                newPage("View Hierarchy (continued)")
                currentY += 5
            }
            draw(heirarchyElement: element)
        }

        UIGraphicsEndPDFContext()
        return pdfData as Data
    }

    var pageSize: CGSize { UIGraphicsGetPDFContextBounds().size }

    let title1: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .center
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle),
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let title2: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1),
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let title3: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2),
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let body: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let unispacedBody: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        let font = UIFont(name: "Menlo-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .regular)
        return [NSAttributedString.Key.font: font,
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let detail: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineBreakMode = .byWordWrapping
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1),
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let warning: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.backgroundColor: UIColor.yellow,
                NSAttributedString.Key.paragraphStyle: style]
    }()

    let error: [NSAttributedString.Key: Any] = {
        var style = NSMutableParagraphStyle()
        style.alignment = .left
        return [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body),
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.backgroundColor: UIColor.red,
                NSAttributedString.Key.paragraphStyle: style]
    }()

    func style(severity: QAFindingSeverity) -> [NSAttributedString.Key: Any] {
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

extension Report {

    func newPage() {
        UIGraphicsBeginPDFPage()
        currentY = padding
    }

    func newPage(_ string: String) {
        newPage()
        draw(string, attributes: title2, xPosition: padding)
        drawRule()
    }

    func drawCentered(_ string: NSAttributedString, rect: CGRect) {
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let stringSize = string.boundingRect(with: rect.size, options: drawingOptions, context: nil)
        string.draw(in: CGRect(x: rect.origin.x + (rect.width - stringSize.width) / 2,
                               y: rect.origin.y + (rect.height - stringSize.height) / 2,
                               width: stringSize.width,
                               height: stringSize.height))
    }

    @discardableResult func draw(_ string: String, attributes: [NSAttributedString.Key: Any], xPosition: CGFloat? = nil,
                                 width: CGFloat? = nil, updateHeight: Bool = true, draw: Bool = true) -> CGSize {
        let xPosition = xPosition ?? padding
        let actualWidth = width ?? (pageSize.width - 2 * padding)
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let boundingSize = CGSize(width: actualWidth, height: .greatestFiniteMagnitude)
        let stringSize = attributedString.boundingRect(with: boundingSize, options: drawingOptions, context: nil)
        if draw && stringSize.height + currentY > pageSize.height {
            newPage()
        }
        let stringRect = CGRect(x: xPosition, y: currentY, width: actualWidth, height: stringSize.height)
        if draw {
            attributedString.draw(in: stringRect)
            if updateHeight {
                currentY += stringRect.height + padding
            }
        }
        return stringSize.size
    }

    @discardableResult func draw(_ image: UIImage?, outline: Bool = true, xPosition: CGFloat? = nil,
                                 width: CGFloat? = nil, updateHeight: Bool = true, draw: Bool = true) -> CGSize {
        guard let image = image else { return .zero }
        let xPosition = xPosition ?? padding
        let actualWidth = width ?? (pageSize.width - xPosition - 2 * padding)
        let scaleW = min(image.size.width, actualWidth) / image.size.width
        let scaleH = min(image.size.height, pageSize.height - currentY - padding) / image.size.height
        let scale = min(scaleW, scaleH)
        let drawRect = CGRect(x: xPosition,
                              y: currentY,
                              width: image.size.width * scale,
                              height: image.size.height * scale)
        if draw {
            image.draw(in: drawRect)
            if outline {
                UIColor.black.set()
                UIRectFrame(drawRect)
            }
            if updateHeight {
                currentY += drawRect.height + padding
            }
        }
        return drawRect.size
    }

    @discardableResult func draw(_ color: UIColor, xPosition: CGFloat? = nil,
                                 updateHeight: Bool = true, draw performDraw: Bool = true) -> CGSize {
        let colorWidth = CGFloat(30)
        let textWidth = CGFloat(120)
        let xPosition = xPosition ?? padding
        let colorRect = CGRect(x: xPosition, y: currentY, width: colorWidth, height: colorWidth)
        if performDraw {
            color.set()
            UIRectFill(colorRect)
            UIColor.black.set()
            UIRectFrame(colorRect)
        }
        let textSize = draw(color.hex, attributes: body, xPosition: xPosition + colorRect.width + padding,
                        width: textWidth, updateHeight: updateHeight, draw: performDraw)
        let height = max(colorRect.height, textSize.height)
        if performDraw && updateHeight {
            currentY += height + padding
        }
        return CGSize(width: 2 * padding + textWidth, height: height)
    }

    @discardableResult func draw(_ finding: Finding, draw performDraw: Bool = true) -> CGFloat {
        let severityWidth = CGFloat(75)
        let severityHeight = CGFloat(40)
        let remainingWidth = pageSize.width - 4 * padding - severityWidth
        let messageWidth = remainingWidth * 0.6
        let screenshotWidth = remainingWidth - messageWidth

        var xPosition = padding

        if performDraw {
            color(severity: finding.severity).set()
            UIRectFill(CGRect(x: xPosition, y: currentY, width: severityWidth, height: severityHeight))
            drawCentered(NSAttributedString(string: finding.severity.rawValue,
                                            attributes: style(severity: finding.severity)),
                                            rect: CGRect(x: xPosition, y: currentY, width: severityWidth, height: 40))
        }
        xPosition += severityWidth + padding
        let size0 = draw(finding.description, attributes: body, xPosition: xPosition, width: messageWidth,
                         updateHeight: false, draw: performDraw)
        let messageX = xPosition
        xPosition += messageWidth + padding
        let size1 = draw(finding.screenshot, xPosition: xPosition, width: screenshotWidth,
                         updateHeight: false, draw: performDraw)
        if performDraw {
            currentY += size0.height + padding / 2
        }
        let size2 = draw(finding.explanation, attributes: detail, xPosition: messageX, width: messageWidth,
                         updateHeight: false, draw: performDraw)

        let rowHeight = max(severityHeight, size0.height + size2.height + padding, size1.height)
        if performDraw {
            currentY += rowHeight - size0.height
        }
        return rowHeight
     }

    @discardableResult func draw(_ element: Element, draw performDraw: Bool = true) -> CGFloat {
        var xPosition = padding
        switch element {
        case .label(let font, let maxLines, let text, let textColor, let base):
            let size0 = draw("\(element.base.depth) Label: \(font.pointSize)pt", attributes: body,
                             xPosition: xPosition, width: 140, updateHeight: false, draw: performDraw)
            xPosition += 140 + padding
            let size1 = draw("\(font.fontName)", attributes: body, xPosition: xPosition, width: 180,
                             updateHeight: false, draw: performDraw)
            xPosition += 180 + padding
            let numberOfLines = element.numberOfLines(text: text, font: font, frame: base.windowFrame)
            let size2 = draw("\(numberOfLines) / \(maxLines) lines", attributes: body, xPosition: xPosition,
                             width: 100, updateHeight: false, draw: performDraw)
            xPosition += 100 + padding
            let size3 = draw(textColor, xPosition: xPosition, updateHeight: false, draw: performDraw)
            let rowHeight = max(size0.height, size1.height, size2.height, size3.height)
            if performDraw {
                currentY += rowHeight + padding
            }
            let sizeText = draw(text, attributes: detail, xPosition: 40, draw: performDraw)
            let height = rowHeight + padding + sizeText.height
            return height
        case .image(let image, let imageAccessibilityLabel, let base):
            let size0 = draw("\(element.base.depth) \(base.className):", attributes: body,
                             xPosition: xPosition, width: 140, updateHeight: false, draw: performDraw)
            xPosition += 140 + padding
            let size1 = draw(imageAccessibilityLabel ?? "{no accessibility label}", attributes: body,
                             xPosition: xPosition, width: 240, updateHeight: false, draw: performDraw)
            xPosition += 240 + padding
            let size2 = draw(image, xPosition: xPosition, width: pageSize.width - xPosition - padding,
                             updateHeight: false, draw: performDraw)
            let rowHeight = max(size0.height, size1.height, size2.height) + padding
            if performDraw {
                currentY += rowHeight
            }
            return rowHeight
        default: break
        }
        return 0
    }

    @discardableResult func draw(heirarchyElement element: Element, draw performDraw: Bool = true) -> CGFloat {
        let spacer = "\(String(format: "%4d ", element.depth)) "
            + String(repeating: "-  ", count: element.base.level)
        let string = "\(element)"
        let size = draw(spacer, attributes: unispacedBody, updateHeight: false, draw: performDraw)
        let rowSize = draw(string, attributes: unispacedBody, xPosition: size.width + padding, draw: performDraw)
        return rowSize.height
    }

    func drawRule(color: UIColor = .gray, height: CGFloat = 1) {
        color.set()
        UIRectFrame(CGRect(x: padding, y: currentY, width: pageSize.width - 2 * padding, height: height))
        currentY += height
    }

    func drawSystemSummary(xPosition: CGFloat? = nil) {
        let xPosition = xPosition ?? padding
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss E MMM d, yyyy"
        let style = unispacedBody
        draw("Bundle ID: \(Bundle.main.bundleIdentifier ?? "")", attributes: style, xPosition: xPosition)
        draw("Date: \(dateFormatter.string(from: Date()))", attributes: style, xPosition: xPosition)
        draw("iOS: \(UIDevice.current.systemVersion)", attributes: style, xPosition: xPosition)
        draw("Device model: \(UIDevice.current.model)", attributes: style, xPosition: xPosition)
        draw("Device name: \(UIDevice.current.name)", attributes: style, xPosition: xPosition)
        draw("Locale: \(Locale.current.languageCode ?? "nil")", attributes: style, xPosition: xPosition)
        if #available(iOS 12.0, *) {
            let mode = details.traitCollection.userInterfaceStyle == .light ? "Light mode" : "Dark mode"
            draw("Mode: \(mode)", attributes: style, xPosition: xPosition)
        }
        draw("Global configuration", attributes: title2, xPosition: xPosition)
        draw("Excluded checks", attributes: body, xPosition: xPosition)
        if UILintConfig.shared.excludedChecks.isEmpty {
            draw("No excluded checks", attributes: style, xPosition: xPosition + padding)
        }
        UILintConfig.shared.excludedChecks.forEach { check in
            draw("\(check.self)", attributes: style, xPosition: xPosition + padding)
        }
        draw("Expected fonts", attributes: body, xPosition: xPosition)
        if UILintConfig.shared.expectedFontNames.isEmpty {
            draw("All fonts are expected", attributes: style, xPosition: xPosition + padding)
        }
        UILintConfig.shared.expectedFontNames.forEach { fontName in
            draw("\(fontName)", attributes: style, xPosition: xPosition + padding)
        }
        currentY += padding
    }

    func drawFirstPage() {
        newPage()
        draw(pdfTitle, attributes: title1)
        let screenshotSize = draw(screenshot, draw: false)
        if screenshotSize.height / screenshotSize.width > 1.3 {
            draw("Screenshot", attributes: title2, updateHeight: false)
            draw("System Details", attributes: title2, xPosition: pageSize.width / 2 + padding)
            draw(screenshot, width: pageSize.width / 2 - padding, updateHeight: false)
            drawSystemSummary(xPosition: pageSize.width / 2 + padding)
        } else {
            draw("System Details", attributes: title2)
            drawSystemSummary()
            draw("Screenshot", attributes: title2)
            draw(screenshot)
        }
    }
}
