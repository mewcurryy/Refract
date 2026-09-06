//
//  ImageGradingEngine.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit
import CoreImage

final class ImageGradingEngine {
    private let context = CIContext()
    
    func applyGrading(to image: CIImage, values: [GradingParameterID: Float]) -> CIImage {
        var output = image
        
        if let colorControls = CIFilter(name: "CIColorControls") {
            colorControls.setValue(output, forKey: kCIInputImageKey)
            colorControls.setValue(GradingMapper.mapFilterValue(sliderValue: values[.brightness] ?? 0, params: .brightness), forKey: kCIInputBrightnessKey)
            colorControls.setValue(GradingMapper.mapFilterValue(sliderValue: values[.contrast] ?? 0, params: .contrast), forKey: kCIInputContrastKey)
            colorControls.setValue(GradingMapper.mapFilterValue(sliderValue: values[.saturation] ?? 0, params: .saturation), forKey: kCIInputSaturationKey)
            
            if let result = colorControls.outputImage {
                output = result
            }
        }
        
        if let vibranceFilter = CIFilter(name: "CIVibrance") {
            vibranceFilter.setValue(output, forKey: kCIInputImageKey)
            vibranceFilter.setValue(GradingMapper.mapFilterValue(sliderValue: values[.vibrance] ?? 0, params: .vibrance), forKey: "inputAmount")
            
            if let result = vibranceFilter.outputImage {
                output = result
            }
        }
        return output
    }
    
    func renderToImage(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
