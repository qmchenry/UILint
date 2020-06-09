//
//  LabelUnexpectedFont.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelUnexpectedFont: Check {
    public let description = "Label uses unexpected font."

    public func findings(forElement element: Element,
                         elements: [Element],
                         windowSize: CGSize,
                         screenshot: UIImage?) -> [Finding] {
        guard case let Element.label(font, _, _, _, _) = element else { return [] }
        guard !UILintConfig.shared.expectedFontNames.isEmpty else { return [] }
        guard !UILintConfig.shared.expectedFontNames.contains(font.fontName) else { return [] }

        let message = "\(description)\n\(element.base.className) font name is '\(font.fontName)'"
        let croppedScreenshot = cropped(screenshot: screenshot, toWindowFrame: element.base.windowFrame)

        let finding = Finding(message: message, severity: .error,
                                screenshot: croppedScreenshot, element: element)
        return [finding]
    }

    public init() {}
}
