//
//  NSImage+Extensions.swift
//  Clipchop
//
//  Created by KrLite on 2024/5/12.
//

import AppKit
<<<<<<< HEAD
=======
import SwiftUICore
>>>>>>> origin/rewrite/main

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage {
        return NSImage(size: newSize, flipped: false) { rect in
            self.draw(in: rect,
                      from: NSRect(origin: CGPoint.zero, size: self.size),
                      operation: NSCompositingOperation.copy,
                      fraction: 1.0)
            return true
        }
    }
}
<<<<<<< HEAD
=======

extension NSImage {
    var averageColor: Color? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)
        let extent = ciImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: inputExtent]) else {
            return nil
        }

        guard let outputImage = filter.outputImage else {
            return nil
        }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

        return Color(red: Double(bitmap[0]) / 255.0, green: Double(bitmap[1]) / 255.0, blue: Double(bitmap[2]) / 255.0, opacity: Double(bitmap[3]) / 255.0)
    }
}
>>>>>>> origin/rewrite/main
