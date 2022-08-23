//
//  ColorTheme.swift
//  SwiftUIColorsFromImage
//
//  Created by Vinicius Nakamura on 20/08/22.
//

import Foundation
import SwiftUI
import Palette

struct ColorTheme {
    let averageColor: Color
    let contrastingTone: Color
    let bodyDark: Color
    let bodyLight: Color
    let ctaColor: Color
    let ctaContrast: Color
    let allColors: [Color]
}

extension ColorTheme {
    static func generate(from image: UIImage) throws -> ColorTheme {
        let baseColor = try getAverage(from: image)
        let palette = image.createPalette()
        
        return expandTheme(baseColor: baseColor, palette: palette)
    }
    
    static func generate(from image: UIImage) async throws -> ColorTheme {
        let baseColor = try getAverage(from: image)
        let palette = await image.createPalette()
        
        return expandTheme(baseColor: baseColor, palette: palette)
    }
    
    private static func expandTheme(baseColor: UIColor, palette: Palette) -> ColorTheme {
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

        // MARK: Body Colors

        let bodyDark = UIColor(
            hue: hue,
            saturation: min(saturation, 0.8),
            brightness: min(brightness, 0.2),
            alpha: alpha
        )

        let bodyLight = UIColor(
            hue: hue,
            saturation: min(saturation, 0.2),
            brightness: max(brightness, 0.9),
            alpha: alpha
        )

        // MARK: CTA Colors

        let ctaColor = UIColor(
            hue: (hue + 0.05).truncatingRemainder(dividingBy: 1),
            saturation: min(saturation * 2, 0.8),
            brightness: min(brightness * 3, 0.9),
            alpha: alpha
        )

        var ctaHue: CGFloat = 0
        var ctaSaturation: CGFloat = 0
        var ctaBrightness: CGFloat = 0
        
        ctaColor.getHue(
            &ctaHue,
            saturation: &ctaSaturation,
            brightness: &ctaBrightness,
            alpha: &alpha
        )

        let ctaContrast = UIColor(
            hue: ctaHue,
            saturation: min(0.1, ctaSaturation),
            brightness: isLight(ctaColor) ? 0.05 : 0.95,
            alpha: alpha
        )
        
        let allColors: [Color] = [
            baseColor,
            palette.lightVibrantColor,
            palette.vibrantColor,
            palette.darkVibrantColor,
            palette.lightMutedColor,
            palette.mutedColor,
            palette.darkMutedColor
        ].compactMap {
            guard let uiColor = $0 else { return nil }
            return Color(uiColor: uiColor)
        }

        return ColorTheme(
            averageColor: Color(uiColor: baseColor),
            contrastingTone: Color(uiColor: contrastingTone),
            bodyDark: Color(uiColor: bodyDark),
            bodyLight: Color(uiColor: bodyLight),
            ctaColor: Color(uiColor: ctaColor),
            ctaContrast: Color(uiColor: ctaContrast),
            allColors: allColors
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
