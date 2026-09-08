//
//  HistogramAnalyzing.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import CoreImage

protocol HistogramAnalyzing {
    func analyze(original: CIImage, graded: CIImage) -> HistogramStats
}
