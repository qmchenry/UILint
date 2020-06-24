//
//  SafeArea.swift
//  
//
//  Created by Quinn McHenry on 6/9/20.
//

import UIKit

public struct SafeArea: Check {
    public let description = "Adhere to the safe area and layout margins defined by UIKit."

    public func findings<T: Element>(forElement element: T, elements: [T], context: LintingContext) -> [Finding] {
        guard let windowFrame = element.base.windowFrame else { return [] }
        guard element.isSafeAreaAware else { return [] }
        guard context.safeAreaRect.union(windowFrame) != context.safeAreaRect else { return [] }

        let explanation = "\(element.base.className) [\(element.base.depth)] [\(windowFrame)] "
            + "extends outside of safe area [\(context.safeAreaRect)]"
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.base.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
