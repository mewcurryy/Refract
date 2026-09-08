//
//  HistogramStats.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import Foundation

struct HistogramStats {
    /// 0.0 ... 1.0 -> pixel yang mentok di highlight
    let highlightClippingPercentage: Double
    
    /// 0.0 -> 1.0 -> pixel yang mentok di shadow
    let shadowClippingPercentage: Double
    
    /// -1.0...1.0 -> deviasi saturation dari "natural range". negatif = terlalu pucat, positif = terlalu jenuh.
    let saturationDeviation: Double
}
