//
//  LabelContrastRatio.swift
//  
//
//  Created by Quinn McHenry on 6/10/20.
//
// https://developer.apple.com/design/human-interface-guidelines/accessibility/overview/color-and-contrast/
//
// Text size            Text weight         Minimum contrast ratio
// Up to 17 pt          Any                 4.5:1
// 18 pt and larger     Any                 3:1
// Any                  Bold                3:1

import UIKit

public struct LabelContrastRatio: Check {
    public let description = "Use strongly contrasting colors to improve readability."

    func backgroundColor(screenshot: UIImage) -> UIColor? {
        // The exact corners occasionally returned unexpected colors, potentially due to antialiasing. Sampling a
        // point in from the corners in x and y seems to solve this.
        let xMin = min(1, screenshot.size.width)
        let yMin = min(1, screenshot.size.height)
        let xMax = max(screenshot.size.width - 2, 0)
        let yMax = max(screenshot.size.height - 2, 0)
        let corners = [
            CGPoint(x: xMin, y: yMin),
            CGPoint(x: xMax, y: yMin),
            CGPoint(x: xMin, y: yMax),
            CGPoint(x: xMax, y: yMax)
        ]
        let colors = screenshot.getPixels(points: corners)
        return UIColor(colors: colors)
    }

    func isValid(contrastRatio: CGFloat, font: UIFont) -> Bool {
        let boldOrLarge = font.pointSize >= 18 || font.isBold
        return boldOrLarge && contrastRatio >= 3 || font.pointSize < 18 && contrastRatio >= 4.5
    }

    public func findings(forElement element: Element, elements: [Element], context: LintingContext) -> [Finding] {
        guard case let Element.label(font, _, _, textColor, base) = element else { return [] }
        guard let screenshot = context.screenshot,
            let cropped = crop(screenshot: screenshot, toWindowFrame: base.windowFrame),
            let bgColor = backgroundColor(screenshot: cropped)
            else { return [] }

        let contrastRatio = textColor.contrastRatio(with: bgColor)
        print("\(contrastRatio) \(textColor.hex) \(bgColor.hex)")
        if isValid(contrastRatio: contrastRatio, font: font) {
            return []
        }

        let explanation = "\(element.base.className) [\(element.base.depth)] textColor: \(textColor.hex)\n"
            + "bgColor: \(bgColor.hex)\ncontrastRatio: \(String(format: "%.2f", contrastRatio))"
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
