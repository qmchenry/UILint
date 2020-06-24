//
//  LabelOffscreen.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelOffscreen: Check {
    public let description = "Label is offscreen."

    public func findings<T: Element>(forElement element: T, elements: [T], context: LintingContext) -> [Finding] {
        guard let element = element as? Label,
            element.isLabelOffscreen(windowSize: context.windowSize) else { return [] }

        let explanation = "\(element.base.className) [\(element.base.depth)] full text is '\(element.text)',"
            + " labelFrame=\(element.base.windowFrame!) screenSize=\(context.windowSize)"
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
