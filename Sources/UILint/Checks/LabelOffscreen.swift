//
//  LabelOffscreen.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelOffscreen: Check {
    public let description = "Label is offscreen."

    public func findings(forElement element: Element, elements: [Element], context: LintingContext) -> [Finding] {
        guard let element = element as? Label,
            element.isLabelOffscreen(windowSize: context.windowSize) else { return [] }

        let explanation = "\(element.className) [\(element.depth)] full text is '\(element.text)',"
            + " labelFrame=\(element.windowFrame!) screenSize=\(context.windowSize)"
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
