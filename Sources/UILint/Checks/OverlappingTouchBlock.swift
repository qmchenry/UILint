//
//  OverlappingTouchBlockCheck.swift
//  
//
//  Created by Quinn McHenry on 6/8/20.
//

import UIKit

public struct OverlappingTouchBlock: Check {
    public let description = "Touches to the target view may be blocked by another view."

    public func findings(forElement element: Element, elements: [Element], details: EnvironmentDetails) -> [Finding] {
        guard element.base.wantsTouches, let windowFrame = element.base.windowFrame else { return [] }

        let overlapping: [Element] = elements.filter {
            $0.base.depth > element.base.depth
            && $0.base.consumesTouches
            && $0.overlaps(element)
        }
        let findings = overlapping.map { checkElement -> Finding in
            let unionBounds = windowFrame.union(checkElement.base.windowFrame!)
            let cropped = details.screenshot?.crop(to: unionBounds, viewSize: details.screenshot!.size)
            let explanation = "\(element.base.className) is obscured by \(checkElement.base.className)"
            let finding = Finding(description: description, explanation: explanation, severity: .error,
                                  screenshot: cropped, element: element)
            return finding
        }
        return findings
    }

    public init() {}
}
