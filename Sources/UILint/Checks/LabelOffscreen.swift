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
        guard element.isLabelOffscreen(windowSize: context.windowSize) else { return [] }

        let explanation = "\(element.base.className) [\(element.base.depth)] full text is '\(element.labelText ?? "")',"
            + " labelFrame=\(element.base.windowFrame!) screenSize=\(context.windowSize)"
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
