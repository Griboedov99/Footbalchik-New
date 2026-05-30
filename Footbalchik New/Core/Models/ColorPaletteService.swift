//
//  MatchSearchBarView.swift
//  Footbalchik
//
//  Created by Nick on 14.03.2026.
//


import UIKit

protocol ColorPaletteProviding {
    func palette(for image: UIImage, cacheKey: String) -> [UIColor]
}

final class ColorPaletteService: ColorPaletteProviding {
    static let shared = ColorPaletteService()
    private init() {}

    private var cache: [String: [UIColor]] = [:]

    func palette(for image: UIImage, cacheKey: String) -> [UIColor] {
        if let cached = cache[cacheKey] { return cached }
        var colors: [UIColor] = []
        if let dominant = image.dominantColor(precision: 5) { colors.append(dominant) }
        if let secondary = colors.first?.withSaturation(multiplier: 0.7).withBrightness(multiplier: 1.2) {
            colors.append(secondary)
        }
        if colors.isEmpty { colors = [UIColor.systemGreen, UIColor.systemBlue] }
        cache[cacheKey] = colors
        return colors
    }
}

extension UIImage {
    func dominantColor(precision: Int = 5) -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        let width = 40, height = 40
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context.data else { return nil }

        let ptr = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        var histogram: [UInt64: Int] = [:]

        for x in 0..<width {
            for y in 0..<height {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                let r = Int(ptr[offset])
                let g = Int(ptr[offset + 1])
                let b = Int(ptr[offset + 2])

                let qr = r >> (8 - precision)
                let qg = g >> (8 - precision)
                let qb = b >> (8 - precision)
                let key = UInt64((qr << 16) | (qg << 8) | qb)

                histogram[key, default: 0] += 1
            }
        }

        guard let (key, _) = histogram.max(by: { $0.value < $1.value }) else { return nil }
        let qr = Int((key >> 16) & 0xFF)
        let qg = Int((key >> 8) & 0xFF)
        let qb = Int(key & 0xFF)

        let scale = CGFloat(255) / (pow(2, CGFloat(precision)) - 1)
        let r = CGFloat(qr) * scale / 255
        let g = CGFloat(qg) * scale / 255
        let b = CGFloat(qb) * scale / 255

        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

extension UIColor {
    func withSaturation(multiplier: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        return UIColor(hue: h, saturation: min(max(s * multiplier, 0), 1), brightness: b, alpha: a)
    }

    func withBrightness(multiplier: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        return UIColor(hue: h, saturation: s, brightness: min(max(b * multiplier, 0), 1), alpha: a)
    }
}
