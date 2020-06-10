//
//  LabelUnexpectedFont.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelUnexpectedFont: Check {
    public let description = "Label uses unexpected font."

    public func findings(forElement element: Element, elements: [Element], details: EnvironmentDetails) -> [Finding] {
        guard case let Element.label(font, _, _, _, _) = element else { return [] }
        guard !UILintConfig.shared.expectedFontNames.isEmpty else { return [] }
        guard !UILintConfig.shared.expectedFontNames.contains(font.fontName) else { return [] }

        let message = "\(description)\n\(element.base.className) font name is '\(font.fontName)'"
        let cropped = crop(screenshot: details.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(message: message, severity: .error, screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
