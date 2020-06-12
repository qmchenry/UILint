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
        guard element.isLabelClippedVertically() else { return [] }
        // todo handle auto font scaling

        let explanation = "\(element.base.className) [\(element.base.depth)] full text is '\(element.labelText ?? "")' "
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
