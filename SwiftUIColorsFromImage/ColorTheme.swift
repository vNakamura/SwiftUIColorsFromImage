//
//  ColorTheme.swift
//  SwiftUIColorsFromImage
//
//  Created by Vinicius Nakamura on 20/08/22.
//

import Foundation
import SwiftUI

struct ColorTheme {
    let averageColor: Color
}

extension ColorTheme {
    static func generate(from image: UIImage) throws -> ColorTheme {
        let baseColor = try getAverage(from: image)

        return ColorTheme(averageColor: Color(uiColor: baseColor))
    }

    private static func getAverage(from image: UIImage) throws -> UIColor {
        let ciImage = CIImage(image: image)!
        let filtered = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: ciImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ])!.outputImage!

        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        context.render(
            filtered,
            toBitmap: &pixel,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(pixel[0]) / 255,
            green: CGFloat(pixel[1]) / 255,
            blue: CGFloat(pixel[2]) / 255,
            alpha: 1
        )
    }
}
