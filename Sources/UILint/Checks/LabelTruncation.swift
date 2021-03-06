//
//  LabelTruncation.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct LabelTruncation: Check {
    public let description = "Label text is truncated."

    public func findings(forElement element: Element, elements: [Element], context: LintingContext) -> [Finding] {
        guard let element = element as? Label, element.isLabelTruncated() else { return [] }
        // todo handle auto font scaling

        let screenSize = (element.windowFrame?.size ?? .zero).string(precision: 2)
        let explanation = """
            \(element.className) [\(element.depth)] full text is '\(element.text)'
            screen size: \(screenSize) required size: \(element.labelSize().string(precision: 2))
            maxLines: \(element.maxLines) required lines: \(element.numberOfLines(label: element))
            """
        let cropped = crop(screenshot: context.screenshot, toWindowFrame: element.windowFrame)
        let finding = Finding(description: description, explanation: explanation, severity: .error,
                              screenshot: cropped, element: element)
        return [finding]
    }

    public init() {}
}
