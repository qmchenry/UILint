//
//  LabelVerticalClipping.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelVerticalClipping: Check {
    public let description = "Label is clipped vertically."

    public func findings(forElement element: Element, elements: [Element], details: EnvironmentDetails) -> [Finding] {
        guard element.isLabelClippedVertically() else { return [] }
        // todo handle auto font scaling

        let message = "\(description)\n\(element.base.className) full text is '\(element.labelText ?? "")' "
        let crcroppedop = crop(screenshot: details.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(message: message, severity: .error, screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
