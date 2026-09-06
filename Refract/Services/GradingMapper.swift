//
//  GradingMapper.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

enum GradingMapper {
    
    private static let sliderScale: Float = 5.0
    
    static func mapFilterValue(sliderValue: Float, params: GradingParameterID) -> Float {
        
        let normalizedScale: Float = sliderValue / sliderScale
        
        switch params {
            // brightness & vibrance netralnya di 0.0, contrast & saturation netralnya di 1.0
        case .brightness:
            return normalizedScale
        case .vibrance:
            return normalizedScale
        case .contrast:
            return 1.0 + normalizedScale
        case .saturation:
            return 1.0 + normalizedScale
        }
        
    }
}
