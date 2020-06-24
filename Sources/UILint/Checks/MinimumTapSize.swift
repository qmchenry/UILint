//
//  MinimumTapSizeCheck.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct MinimumTapSize: Check {
    public let description = "Provide ample touch targets for interactive elements."

    public func findings<T: Element>(forElement element: T, elements: [T], context: LintingContext) -> [Finding] {
        guard element.base.wantsTouches, let windowFrame = element.base.windowFrame else { return [] }
        guard windowFrame.size.height < 44 || windowFrame.size.width < 44 else { return [] }

        let cropped = context.screenshot?.crop(to: windowFrame, viewSize: context.screenshot!.size)
        let explanation = "\(element.base.className) [\(element.base.depth)] width/height is "
                      + "less than 44pt (\(windowFrame.width),\(windowFrame.height))"
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
