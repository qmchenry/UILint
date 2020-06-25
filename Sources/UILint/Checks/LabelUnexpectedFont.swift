//
//  LabelUnexpectedFont.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelUnexpectedFont: Check {
    public let description = "Label uses unexpected font."

    public func findings(forElement element: Element, elements: [Element], context: LintingContext) -> [Finding] {
        guard let element = element as? Label else { return [] }
        guard !UILintConfig.shared.expectedFontNames.isEmpty else { return [] }
        guard !UILintConfig.shared.expectedFontNames.contains(element.font.fontName) else { return [] }

        let explanation = "\(element.className) [\(element.depth)] font name is '\(element.font.fontName)'"
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
