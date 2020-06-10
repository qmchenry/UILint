//
//  MinimumTapSizeCheck.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct MinimumTapSize: Check {
    public let description = "Provide ample touch targets for interactive elements."

    public func findings(forElement element: Element,
                         elements: [Element],
                         windowSize: CGSize,
                         safeAreaRect: CGRect,
                         screenshot: UIImage?) -> [Finding] {
        guard element.base.wantsTouches, let windowFrame = element.base.windowFrame else { return [] }
        guard windowFrame.size.height < 44 || windowFrame.size.width < 44 else { return [] }

        let cropped = screenshot?.crop(to: windowFrame, viewSize: screenshot!.size)
        let message = "\(description)\n\(element.base.className) width/height is "
                      + "less than 44pt (\(windowFrame.width),\(windowFrame.height))"
        let finding = Finding(message: message, severity: .error, screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
