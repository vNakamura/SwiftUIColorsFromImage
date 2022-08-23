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
    let contrastingTone: Color
    let bodyDark: Color
    let bodyLight: Color
    let ctaColor: Color
    let ctaContrast: Color
}

extension ColorTheme {
    static func generate(from image: UIImage) throws -> ColorTheme {
        let baseColor = try getAverage(from: image)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        baseColor.getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )

        let contrastingTone = isLight(baseColor) ?
            UIColor(
                hue: hue,
                saturation: 0.9,
                brightness: 0.1,
                alpha: alpha
            ) :
            UIColor(
                hue: hue,
                saturation: min(saturation, 0.15),
                brightness: 0.95,
                alpha: alpha
            )

        return ColorTheme(
            averageColor: Color(uiColor: baseColor),
            contrastingTone: Color(uiColor: contrastingTone),
            bodyDark: .black,
            bodyLight: .white,
            ctaColor: .blue,
            ctaContrast: .white
        )
    }

    private static func isLight(_ color: UIColor) -> Bool {
        var white: CGFloat = 0
        var alpha: CGFloat = 0

        color.getWhite(&white, alpha: &alpha)

        return white >= 0.5
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
