//
//  RealHistogramAnalyzer.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import CoreImage
import CoreGraphics

final class RealHistogramAnalyzer: HistogramAnalyzing {
    private let context = CIContext()
    private let sampleSize = 100
    
    private let highlightThreshold: Double = 250
    private let shadowThreshold: Double = 5
    
    func analyze(original: CIImage, graded: CIImage) -> HistogramStats {
        guard let gradedPixels = samplePixels(from: graded) else {
            return HistogramStats(highlightClippingPercentage: 0, shadowClippingPercentage: 0, saturationDeviation: 0)
        }
        
        var highlightClipped = 0
        var shadowClipped = 0
        var gradedTotalSaturation: Double = 0
        let pixelCount = gradedPixels.count / 4
        
        guard pixelCount > 0 else {
            return HistogramStats(highlightClippingPercentage: 0, shadowClippingPercentage: 0, saturationDeviation: 0)
        }
        
        for i in stride(from: 0, to: gradedPixels.count, by: 4) {
            let r = Double(gradedPixels[i])
            let g = Double(gradedPixels[i + 1])
            let b = Double(gradedPixels[i + 2])
            
            let luminance = 0.299 * r + 0.587 * g + 0.114 * b
            if luminance >= highlightThreshold { highlightClipped += 1 }
            if luminance <= shadowThreshold { shadowClipped += 1 }
            
            let maxC = max(r, g, b)
            let minC = min(r, g, b)
            gradedTotalSaturation += maxC == 0 ? 0 : (maxC - minC) / maxC
        }
        
        let gradedAvgSaturation = gradedTotalSaturation / Double(pixelCount)
        
        // TAMBAHAN — baseline sekarang dari foto ASLI, bukan angka absolut universal
        let originalAvgSaturation = averageSaturation(of: original)
        
        // deviation relatif terhadap titik awal foto itu sendiri
        // dijaga dari divide-by-zero kalau foto originalnya nyaris grayscale total
        let safeBaseline = max(originalAvgSaturation, 0.05)
        let saturationDeviation = (gradedAvgSaturation - originalAvgSaturation) / safeBaseline
        
        return HistogramStats(
            highlightClippingPercentage: Double(highlightClipped) / Double(pixelCount),
            shadowClippingPercentage: Double(shadowClipped) / Double(pixelCount),
            saturationDeviation: saturationDeviation
        )
    }
    
    private func averageSaturation(of image: CIImage) -> Double {
        guard let pixels = samplePixels(from: image) else { return 0 }
        var total: Double = 0
        let pixelCount = pixels.count / 4
        guard pixelCount > 0 else { return 0 }
        
        for i in stride(from: 0, to: pixels.count, by: 4) {
            let r = Double(pixels[i])
            let g = Double(pixels[i + 1])
            let b = Double(pixels[i + 2])
            let maxC = max(r, g, b)
            let minC = min(r, g, b)
            total += maxC == 0 ? 0 : (maxC - minC) / maxC
        }
        return total / Double(pixelCount)
    }
    
    private func samplePixels(from image: CIImage) -> [UInt8]? {
        let extent = image.extent
        guard extent.width > 0, extent.height > 0 else { return nil }
        
        let scaleX = CGFloat(sampleSize) / extent.width
        let scaleY = CGFloat(sampleSize) / extent.height
        let scaled = image.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(scaled, from: CGRect(x: 0, y: 0, width: sampleSize, height: sampleSize)) else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let bitmapContext = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        
        bitmapContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixelData
    }
}
