//
//  OverlappingTouchBlockCheck.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct OverlappingTouchBlock: Check {
    public let description = "An element is blocking tappable area of another element."

    public func findings(forElement element: Element, elements: [Element], context: LintingContext) -> [Finding] {
        guard element.wantsTouches, let windowFrame = element.windowFrame else { return [] }

        let overlapping = elements.filter {
            $0.depth > element.depth
            && $0.consumesTouches
            && $0.overlaps(element)
        }
        let findings = overlapping.map { checkElement -> Finding in
            let unionBounds = windowFrame.union(checkElement.windowFrame!)
            let cropped = context.screenshot?.crop(to: unionBounds, viewSize: context.screenshot!.size)
            let explanation = "\(element.className) [\(element.depth)] is obscured by "
                + "\(checkElement.className) [\(checkElement.depth)]"
            let finding = Finding(description: description, explanation: explanation, severity: .error,
                                  screenshot: cropped, element: element)
            return finding
        }
        return findings
    }

    public init() {}
}
