//
//  PlaceholderHistogramAnalyzer.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import CoreImage

// using real stub
final class PlaceholderHistogramAnalyzer: HistogramAnalyzing { // pake protocol HistogramAnalyzing
    func analyze(_ image: CIImage) -> HistogramStats {
        HistogramStats(highlightClippingPercentage: 0, shadowClippingPercentage: 0, saturationDeviation: 0)
    }
}
