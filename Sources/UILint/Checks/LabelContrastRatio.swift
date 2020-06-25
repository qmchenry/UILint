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

    func isValid(contrastRatio: CGFloat, font: UIFont) -> Bool {
    let boldOrLarge = font.pointSize >= 18 || font.isBold
        return boldOrLarge && contrastRatio >= 3 || font.pointSize < 18 && contrastRatio >= 4.5
    }

    public func findings(forElement element: Element, elements: [Element], context: LintingContext) -> [Finding] {
        guard let element = element as? Label else { return [] }
        guard let screenshot = context.screenshot,
            let cropped = crop(screenshot: screenshot, toWindowFrame: element.windowFrame),
            let bgColor = element.effectiveBackgroundColor,
            let textCGColor = element.textColor.cgColor.toColorSpace(name: CGColorSpace.sRGB),
            let contrastRatio = textCGColor.contrastRatio(with: bgColor)
            else {
                print("couldn't compute contrast ratio \(element)")
                return []
            }

        print("CR \(contrastRatio) \(element.textColor.hex) \(bgColor.hex)")
        if isValid(contrastRatio: contrastRatio, font: element.font) {
            return []
        }

        let explanation = "\(element.className) [\(element.depth)] textColor: \(element.textColor.hex)\n"
            + "bgColor: \(bgColor.hex)\ncontrastRatio: \(String(format: "%.2f", contrastRatio))"
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
