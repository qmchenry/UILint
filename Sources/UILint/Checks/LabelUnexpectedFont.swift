//
//  LabelUnexpectedFont.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelUnexpectedFont: QACheck {
    public let description = "Label uses unexpected font."

    public func findings(forElement element: QAElement,
                         elements: [QAElement],
                         windowSize: CGSize,
                         screenshot: UIImage?) -> [QAFinding] {
        guard case let QAElement.label(font, _, _, _, _) = element else { return [] }
        guard !QAConfig.expectedFontNames.isEmpty,
            !QAConfig.expectedFontNames.contains(font.fontName) else { return [] }

        let message = "\(description)\n\(element.base.className) font name is '\(font.fontName)'"
        let croppedScreenshot = cropped(screenshot: screenshot, toWindowFrame: element.base.windowFrame)

        let finding = QAFinding(message: message, severity: .error,
                                screenshot: croppedScreenshot, element: element)
        return [finding]
    }

    public init() {}
}
