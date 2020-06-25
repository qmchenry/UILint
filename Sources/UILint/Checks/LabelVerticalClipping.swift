//
//  LabelVerticalClipping.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelVerticalClipping: Check {
    public let description = "Label is clipped vertically."

    public func findings(forElement element: Element, elements: [Element], context: LintingContext) -> [Finding] {
        guard let element = element as? Label, element.isLabelClippedVertically() else { return [] }
        // todo handle auto font scaling

        let explanation = "\(element.className) [\(element.depth)] full text is '\(element.text)' "
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
