//
//  LabelTruncation.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelTruncation: Check {
    public let description = "Label text is truncated."

    public func findings(forElement element: Element, elements: [Element], details: EnvironmentDetails) -> [Finding] {
        guard element.isLabelTruncated() else { return [] }
        // todo handle auto font scaling

        let message = "\(description)\n\(element.base.className) full text is '\(element.labelText ?? "")' "
        let cropped = crop(screenshot: details.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(message: message, severity: .error, screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
