//
//  SafeArea.swift
//  
//
//  Created by Quinn McHenry on 6/9/20.
//

import UIKit

public struct SafeArea: Check {
    public let description = "Adhere to the safe area and layout margins defined by UIKit."

    public func findings(forElement element: Element, elements: [Element], details: EnvironmentDetails) -> [Finding] {
        guard let windowFrame = element.base.windowFrame else { return [] }
        guard element.isLabel || element.isButton || element.isImage else { return [] }
        guard details.safeAreaRect.union(windowFrame) != details.safeAreaRect else { return [] }

        let explanation = "\(element.base.className) [\(element.base.depth)] [\(windowFrame)] "
            + "extends outside of safe area [\(details.safeAreaRect)]"
        let cropped = crop(screenshot: details.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
