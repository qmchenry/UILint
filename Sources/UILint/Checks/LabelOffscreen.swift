//
//  LabelOffscreen.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelOffscreen: Check {
    public let description = "Label is offscreen."

    public func findings(forElement element: Element,
                         elements: [Element],
                         windowSize: CGSize,
                         screenshot: UIImage?) -> [Finding] {
        guard element.isLabelOffscreen(windowSize: windowSize) else { return [] }

        let message = "\(description)\n\(element.base.className) full text is '\(element.labelText ?? "")',"
        + " labelFrame=\(element.base.windowFrame!) screenSize=\(windowSize)"
        let croppedScreenshot = cropped(screenshot: screenshot, toWindowFrame: element.base.windowFrame)

        let finding = Finding(message: message, severity: .error,
                                screenshot: croppedScreenshot, element: element)
        return [finding]
    }

    public init() {}
}
