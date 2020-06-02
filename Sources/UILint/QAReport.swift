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

        @discardableResult func draw(_ string: String, attributes: [NSAttributedString.Key : Any], x: CGFloat = padding, width: CGFloat? = nil, updateHeight: Bool = true) -> CGSize {
            let actualWidth = width ?? (pageSize.width - 2 * padding)
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
            let stringSize = attributedString.boundingRect(with: CGSize(width: actualWidth, height: .greatestFiniteMagnitude), options: drawingOptions, context: nil)
            print("'\(string)' \(stringSize) \(attributedString.size())")
            if stringSize.height + currentY > pageSize.height {
                newPage()
            }
            let stringRect = CGRect(x: x, y: currentY, width: actualWidth, height: stringSize.height)
            attributedString.draw(in: stringRect)
            if updateHeight {
                currentY += stringRect.height + padding
            }
            return stringSize.size
        }
        
        @discardableResult func draw(_ image: UIImage?, x: CGFloat = padding, width: CGFloat? = nil) -> CGSize {
            guard let image = image else { return .zero }
            let actualWidth = width ?? (pageSize.width - 2 * padding)
            let scaleW = min(image.size.width, pageSize.width - x - padding) / image.size.width
            let scaleH = min(image.size.height, pageSize.height - currentY - padding) / image.size.height
            let scale = min(scaleW, scaleH)
            let drawRect = CGRect(x: x, y: currentY, width: image.size.width * scale, height: image.size.height * scale)
            image.draw(in: drawRect)
            return drawRect.size
        }

        newPage()

        draw(pdfTitle, attributes: h1)
        draw("Screenshot", attributes: h2, x: padding)
        draw(screenshot)

        newPage()
        
        draw("Findings", attributes: h2, x: padding)

        let severityWidth = CGFloat(60)
        let remainingWidth = pageSize.width - padding - severityWidth
        let messageWidth = (remainingWidth - padding) * 0.6
        let screenshotWidth = remainingWidth - messageWidth
        
        findings.forEach { finding in
            currentY += 5
            var x = paddingLarge
            draw(" \(finding.severity.rawValue) ", attributes: style(severity: finding.severity), x: x, width: severityWidth, updateHeight: false)
            x += severityWidth
            let size1 = draw(finding.message, attributes: body, x: x, width: messageWidth, updateHeight: false)
            x += padding + messageWidth
            let size2 = draw(finding.screenshot, x: x, width: screenshotWidth)            
            currentY += max(size1.height, size2.height) + padding
        }

        
        draw("Here is more text, body this time!", attributes: body, x: padding)
        draw("Pie oat cake biscuit jelly lemon drops cupcake chocolate bar danish. Powder marshmallow liquorice chocolate. Biscuit wafer powder. Liquorice bonbon cake donut jujubes cake. Wafer ice cream sugar plum chocolate cake cake. Cake muffin cupcake oat cake. Pastry gummi bears gummies pie wafer. Halvah brownie topping. Danish apple pie dessert fruitcake soufflé. Candy canes macaroon marshmallow liquorice donut pudding soufflé. Macaroon jelly beans lollipop chocolate cake dragée chocolate bar cookie tiramisu bonbon. Wafer dessert cheesecake. Gummies tiramisu sweet roll muffin macaroon cake donut. Sweet roll candy canes chocolate bar lemon drops halvah soufflé chocolate topping.", attributes: body, x: padding)
        draw("Title with h2", attributes: h2, x: padding)
        draw("Here is more text, body this time!", attributes: body, x: padding)

        // Closes the current PDF context and ends writing to the file.
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


//    public func makeSimplePDF(elements: [QAElement], findings: [QAFinding], screenshot: UIImage?) -> Data {
//        let pdf = SimplePDF(pageSize: CGSize(width: 850, height: 1100))
//
//        let h1 = UIFont.systemFont(ofSize: 24, weight: .heavy)
//        let h2 = UIFont.systemFont(ofSize: 18, weight: .heavy)
//        let h3 = UIFont.systemFont(ofSize: 12, weight: .bold)
//        let body = UIFont.systemFont(ofSize: 12, weight: .regular)
//
//        pdf.addText("UILint Report", font: h1)
//        pdf.addVerticalSpace(10)
//        pdf.addText("Generated at \(Date())", font: h3)
//        pdf.addVerticalSpace(20)
//
//        if let screenshot = screenshot {
//            pdf.addText("Full screenshot", font: h2)
//            pdf.addVerticalSpace(20)
//            pdf.addImage(screenshot)
//            pdf.beginNewPage()
//        }
//
//        pdf.addText("Findings", font: h1, textColor: .black)
//
//        pdf.addVerticalSpace(15)
//        pdf.addLineSeparator(height: 0.1)
//
//        findings.forEach { finding in
//            pdf.addVerticalSpace(5)
//            pdf.beginHorizontalArrangement()
//            pdf.addText(finding.severity.rawValue, font: h3, textColor: finding.severity.textColor)
//            pdf.addHorizontalSpace(10)
//            pdf.addText(finding.message, font: body)
//            pdf.endHorizontalArrangement()
//            if let croppedScreenshot = finding.screenshot {
//                pdf.setContentAlignment(.right)
//                pdf.addImage(croppedScreenshot)
//                pdf.setContentAlignment(.left)
//            }
//            pdf.addVerticalSpace(5)
//            pdf.addLineSeparator(height: 0.1)
//        }
//
//        pdf.beginNewPage()
//
//        pdf.addText("Elements", font: h1, textColor: .black)
//
//        pdf.addVerticalSpace(20)
//
//        pdf.addText("Labels", font: h2, textColor: .black)
//        pdf.addVerticalSpace(10)
//
//        pdf.addLineSeparator(height: 0.1)
//
//        elements.forEach { element in
//            switch element {
//            case .label(let font, let maxLines, let text, _):
//                pdf.addVerticalSpace(10)
//                pdf.addText("\(font.pointSize)pt \(font.fontName), maxLines=\(maxLines)", font: h3)
//                pdf.addText(text, font: body)
//                pdf.addVerticalSpace(10)
//                pdf.addLineSeparator(height: 0.1)
//            default: break
//            }
//        }
//
//        return pdf.generatePDFdata()
//    }
}
