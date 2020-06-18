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

    func crop(to rect: CGRect?, viewSize: CGSize?) -> UIImage? {
        guard let rect = rect, let viewSize = viewSize else { return nil }
        return crop(to: rect, viewSize: viewSize)
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

struct RGBA {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

extension CGColor {
    var rgbaComponents: RGBA {
        guard let components = components else {
            return RGBA(red: 0, green: 0, blue: 0, alpha: 0)
        }
        switch components.count {
        case 4: return RGBA(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        case 3: return RGBA(red: components[0], green: components[1], blue: components[2], alpha: 1)
        case 2: return RGBA(red: components[0], green: components[0], blue: components[0], alpha: components[1])
        default: return RGBA(red: 0, green: 0, blue: 0, alpha: 0)
        }
    }

    var rgbaCapped: RGBA {
        let rgba = rgbaComponents
        func cap(_ value: CGFloat) -> CGFloat {
            return min(1, max(0, value))
        }
        return RGBA(red: cap(rgba.red), green: cap(rgba.green), blue: cap(rgba.blue), alpha: cap(rgba.alpha))
    }

    var hex: String {
        let rgba = rgbaCapped
        return String(format: "%02lX%02lX%02lX%02lX",
                      lroundf(Float(rgba.red) * 255),
                      lroundf(Float(rgba.green) * 255),
                      lroundf(Float(rgba.blue) * 255),
                      lroundf(Float(rgba.alpha) * 255))
    }

    func toColorSpace(name: CFString, intent: CGColorRenderingIntent = .defaultIntent) -> CGColor? {
        converted(to: CGColorSpace(name: name)!, intent: intent, options: nil)
    }

    func toColorSpace(colorSpace: CGColorSpace, intent: CGColorRenderingIntent = .defaultIntent) -> CGColor? {
        converted(to: colorSpace, intent: intent, options: nil)
    }

    var toSRGB: CGColor? {
        toColorSpace(name: CGColorSpace.sRGB)
    }

    func luminance() -> CGFloat? {
        guard let components = components, components.count >= 2 else {
            return nil
        }
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests

        func adjust(_ colorComponent: CGFloat) -> CGFloat {
            return (colorComponent < 0.04045) ? (colorComponent / 12.92) : pow((colorComponent + 0.055) / 1.055, 2.4)
        }
        if components.count == 2 {
            return (0.2126 + 0.7152 + 0.0722) * adjust(components[0])
        }
        return 0.2126 * adjust(components[0]) + 0.7152 * adjust(components[1]) + 0.0722 * adjust(components[2])
    }

    // Luminance and contrast ratio computation code from
    // https://stackoverflow.com/questions/42355778/how-to-compute-color-contrast-ratio-between-two-uicolor-instances
    static func contrastRatio(between color1: CGColor, and color2: CGColor) -> CGFloat? {
        // https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
        guard let luminance1 = color1.luminance(), let luminance2 = color2.luminance() else { return nil }
        let luminanceDarker = min(luminance1, luminance2)
        let luminanceLighter = max(luminance1, luminance2)
        return (luminanceLighter + 0.05) / (luminanceDarker + 0.05)
    }

    func contrastRatio(with color: CGColor) -> CGFloat? {
        return Self.contrastRatio(between: self, and: color)
    }

    public static func average(colors: [CGColor]) -> CGColor? {
        guard colors.count > 0 else { return nil }
        let sum: [CGFloat] = colors.reduce([0, 0, 0, 0]) { (sum, color) in
            guard let rgba = color.components else { return sum }
            let alpha = rgba.count == 4 ? rgba[3] : 1
            return [sum[0]+rgba[0], sum[1]+rgba[1], sum[2]+rgba[2], sum[3]+alpha]
        }
        let count = CGFloat(colors.count)
        return UIColor(red: sum[0] / count, green: sum[1] / count, blue: sum[2] / count, alpha: sum[3] / count).cgColor
    }
}

extension UIColor {

    // Hex string representation from UIColor
    var hex: String {
        return cgColor.hex
    }

    var rgba: [CGFloat] {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return [red, green, blue, alpha]
    }

    func contrastRatio(with color: UIColor) -> CGFloat? {
        cgColor.contrastRatio(with: color.cgColor)
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
    func getPixels(points: [CGPoint]) -> [CGColor] {
        let rects = points.map { CGRect(origin: $0, size: CGSize(width: 1, height: 1)) }
        let colors = rects.compactMap { averageColor(rect: $0)?.cgColor }
        print(colors)
        return colors
    }

    func averageColor(rect: CGRect? = nil, colorSpace colorSpaceName: CFString = CGColorSpace.sRGB) -> UIColor? {
        let rect = rect ?? CGRect(origin: .zero, size: size)
        guard let bitDepth = cgImage?.bitsPerPixel, bitDepth == 32 || bitDepth == 64 else { return nil }
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: rect.origin.x, y: rect.origin.y, z: rect.size.width, w: rect.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]),
            let outputImage = filter.outputImage
            else { return nil }

        let format: CIFormat = bitDepth == 32 ? .RGBA8 : .RGBA16
        let space = CGColorSpace(name: colorSpaceName)!
        let context: CIContext = {
            var options = [CIContextOption: Any]()
            options[.workingColorSpace] = space
            options[.workingFormat] = NSNumber(value: format.rawValue)
            return CIContext(options: options)
        }()

        if bitDepth == 64 {
            var bitmap = [UInt16](repeating: 0, count: 4)
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 8,
                           bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: format, colorSpace: space)
            return UIColor(red: CGFloat(bitmap[0])/65535,
                           green: CGFloat(bitmap[1])/65535,
                           blue: CGFloat(bitmap[2])/65535,
                           alpha: CGFloat(bitmap[3])/65535)
        } else {
            var bitmap = [UInt8](repeating: 0, count: 4)
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4,
                           bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: format, colorSpace: space)
            return UIColor(red: CGFloat(bitmap[0])/255,
                           green: CGFloat(bitmap[1])/255,
                           blue: CGFloat(bitmap[2])/255,
                           alpha: CGFloat(bitmap[3])/255)
        }
    }

    func effectiveBackgroundColor() -> CGColor? {
        // The exact corners occasionally returned unexpected colors, potentially due to antialiasing. Sampling a
        // point in from the corners in x and y seems to solve this.
        let xMin = min(1, size.width)
        let yMin = min(1, size.height)
        let xMax = max(size.width - 2, 0)
        let yMax = max(size.height - 2, 0)
        let corners = [
            CGPoint(x: xMin, y: yMin),
            CGPoint(x: xMax, y: yMin),
            CGPoint(x: xMin, y: yMax),
            CGPoint(x: xMax, y: yMax)
        ]
        let colors = getPixels(points: corners)
        return CGColor.average(colors: colors)
    }
}

extension UIFont {
    var isBold: Bool {
        fontDescriptor.symbolicTraits.contains(.traitBold)
    }
}

extension UIDisplayGamut {
    var name: String {
        switch self {
        case .P3: return "Display P3"
        case .SRGB: return "sRGB"
        default: return "Unknown"
        }
    }
}
