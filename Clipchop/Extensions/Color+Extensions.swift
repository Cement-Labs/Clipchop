//
//  Color+Extensions.swift
//  Clipchop
//
//  Created by Xinshao_Air on 2024/7/6.
//

import SwiftUI
import Defaults
import AppKit
import CoreImage

extension NSImage {
    func dominantColor() -> NSColor? {
        guard let inputImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil).flatMap({ CIImage(cgImage: $0) }) else { return nil }

        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: inputImage,
            kCIInputExtentKey: extentVector
        ]) else { return nil }

        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        return NSColor(red: CGFloat(bitmap[0]) / 255.0,
                       green: CGFloat(bitmap[1]) / 255.0,
                       blue: CGFloat(bitmap[2]) / 255.0,
                       alpha: CGFloat(bitmap[3]) / 255.0)
    }
}

extension Color {
    static func getAccent() -> Color {
        return inlineAccentColor(style: Defaults[.colorStyle], customColor: Defaults[.customAccentColor])
    }
    
    static func inlineAccentColor(style: ColorStyle, customColor: Color) -> Color {
        switch style {
        case .app:
            return .accent
        case .system:
            return .blue
        case .custom:
            return customColor
        }
    }
}

extension Color {
    var brightness: Double {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return 0
        }
        let red = Double(components[0] * 255)
        let green = Double(components[1] * 255)
        let blue = Double(components[2] * 255)
        return (red * 299 + green * 587 + blue * 114) / 1000
    }

    var isLight: Bool {
        return brightness > 128
    }
}
