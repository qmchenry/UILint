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
        let corners = [
            CGPoint.zero,
            CGPoint(x: screenshot.size.width, y: 0),
            CGPoint(x: 0, y: screenshot.size.height),
            CGPoint(x: screenshot.size.width, y: screenshot.size.height)
        ]
        let colors = corners.compactMap { screenshot.getPixelColor($0) }
        return UIColor(colors: colors)
    }

    public func findings(forElement element: Element, elements: [Element], details: EnvironmentDetails) -> [Finding] {
        guard case let Element.label(font, _, _, textColor, base) = element else { return [] }
        guard let screenshot = details.screenshot,
            let cropped = crop(screenshot: screenshot, toWindowFrame: base.windowFrame),
            let bgColor = backgroundColor(screenshot: cropped)
            else { return [] }

        let contrastRatio = textColor.contrastRatio(with: bgColor)
        let boldOrLarge = font.pointSize >= 18 // or isBold
        if boldOrLarge && contrastRatio >= 3 || font.pointSize < 18 && contrastRatio >= 4.5 {
            return []
        }

        let explanation = "\(element.base.className) [\(element.base.depth)] textColor: '\(textColor.hex)' + "
            + " bgColor: \(bgColor) -> contrastRatio: \(contrastRatio)"
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
