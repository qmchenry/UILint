//
//  UIKitHelpers.swift
//  UILint
//
//  Created by Quinn McHenry on 5/26/20.
//

import UIKit

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self))
    }
}

extension UIView {
    func parentViewController() -> UIViewController? {
        if let ancestor = self.next as? UIViewController {
            return ancestor.topmostViewController()
        } else if let ancestor = self.next as? UIView {
            return ancestor.parentViewController()
        } else {
            return nil
        }
    }

    // View's frame in global/window coordinates
    var windowFrame: CGRect? {
        superview?.convert(frame, to: parentViewController()?.view)
    }

    // Return an array of all subviews including those not included in the
    // default subviews property
    var allSubviews: [UIView] {
        if let view = self as? UICollectionView {
            return view.visibleCells
        }
        return subviews
    }

    var consumesTouches: Bool {
        // todo consider multiple points (8 points perimeter and center) but how to handle partial hits?
        // todo handle layer transform
        let hitView = hitTest(CGPoint(x: bounds.size.width/2, y: bounds.size.height/2), with: nil)
        return hitView === self
    }
}

extension UIImage {
    func crop(to rect: CGRect, viewSize: CGSize) -> UIImage {
        let cropScale = max(size.width/viewSize.width, size.height/viewSize.height) * scale
        let cropRect = CGRect(x: rect.origin.x * cropScale,
                              y: rect.origin.y * cropScale,
                              width: rect.size.width * cropScale,
                              height: rect.size.height * cropScale)
        guard let cropped = cgImage?.cropping(to: cropRect) else {
            return UIImage()
        }
        return UIImage(cgImage: cropped)
    }
}

extension UIViewController {
    @objc func topmostViewController() -> UIViewController {
        // Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topmostViewController()
        }
        // Follow responder chain
        for subview in view.subviews {
            if let subViewController = subview.next as? UIViewController {
                return subViewController.topmostViewController()
            }
        }
        return self
    }
}

extension UITabBarController {
    override func topmostViewController() -> UIViewController {
        return selectedViewController?.topmostViewController() ?? self
    }
}

extension UINavigationController {
    override func topmostViewController() -> UIViewController {
        return visibleViewController?.topmostViewController() ?? self
    }
}

extension UIColor {

    // Hex string representation from UIColor
    var hex: String {
        guard let components = cgColor.components, components.count >= 2 else {
            return "#00000000"
        }
        let alpha: Float
        if components.count >= 4 {
            alpha = Float(components[3])
        } else if components.count == 2 {
            alpha = Float(components[1])
        } else {
            alpha = 1
        }
        if components.count == 2 {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(components[0]) * 255),
                          lroundf(Float(components[0]) * 255),
                          lroundf(Float(components[0]) * 255),
                          lroundf(alpha * 255))
        }
        return String(format: "#%02lX%02lX%02lX%02lX",
                      lroundf(Float(components[0]) * 255),
                      lroundf(Float(components[1]) * 255),
                      lroundf(Float(components[2]) * 255),
                      lroundf(alpha * 255))
    }

    // Luminance and contrast ratio computation code from
    // https://stackoverflow.com/questions/42355778/how-to-compute-color-contrast-ratio-between-two-uicolor-instances
    static func contrastRatio(between color1: UIColor, and color2: UIColor) -> CGFloat {
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests

        let luminance1 = color1.luminance()
        let luminance2 = color2.luminance()

        let luminanceDarker = min(luminance1, luminance2)
        let luminanceLighter = max(luminance1, luminance2)

        return (luminanceLighter + 0.05) / (luminanceDarker + 0.05)
    }

    func contrastRatio(with color: UIColor) -> CGFloat {
        return UIColor.contrastRatio(between: self, and: color)
    }

    func luminance() -> CGFloat {
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests

        let ciColor = CIColor(color: self)

        func adjust(colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * adjust(colorComponent: ciColor.red)
            + 0.7152 * adjust(colorComponent: ciColor.green)
            + 0.0722 * adjust(colorComponent: ciColor.blue)
    }

    var rgba: [CGFloat] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }

    convenience init(components: [CGFloat]) {
        if components.count == 3 {
            self.init(red: components[0], green: components[1], blue: components[2], alpha: 1)
        } else if components.count == 4 {
            self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        } else if components.count == 1 {
            self.init(red: 0, green: 0, blue: 0, alpha: components[0])
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }

    convenience init?(colors: [UIColor]) {
        guard colors.count > 0 else { return nil }
        let sum: [CGFloat] = colors.reduce([0, 0, 0, 0]) { (sum, color) in
            let rgba = color.rgba
            return [sum[0]+rgba[0], sum[1]+rgba[1], sum[2]+rgba[2], sum[3]+rgba[3]]
        }
        let count = CGFloat(colors.count)
        self.init(red: sum[0] / count, green: sum[1] / count, blue: sum[2] / count, alpha: sum[3] / count)
    }
}

extension UIImage {
    func getPixels(points: [CGPoint]) -> [UIColor] {
        guard let cgImage = self.cgImage,
            cgImage.bitsPerPixel == 32,
            cgImage.bitsPerComponent == 8,
            let imageData = cgImage.dataProvider?.data as Data?
        else {
            return []
        }
        let size = cgImage.width * cgImage.height
        let buffer = UnsafeMutableBufferPointer<UInt32>.allocate(capacity: size)
        _ = imageData.copyBytes(to: buffer)
        let indexes = points.map { point -> Int in
            Int(point.x) + Int(point.y) * Int(cgImage.width)
        }
        guard indexes.filter({ $0 < 0 || $0 >= buffer.count }).isEmpty else { return [] }
        let colors = indexes.map { index -> UIColor in
            let pixel = buffer[index]
            return UIColor(red: CGFloat(pixel & 255) / 255.0,
                           green: CGFloat((pixel >> 8) & 255) / 255.0,
                           blue: CGFloat((pixel >> 16) & 255) / 255.0,
                           alpha: CGFloat((pixel >> 24) & 255) / 255.0)
        }
        return colors
    }
}

extension UIFont {
    var isBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }
}
