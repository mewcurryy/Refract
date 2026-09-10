//
//  PracticeChallenge.swift
//  Refract
//
//  Created by Davin P on 10/09/26.
//


import Foundation

struct PracticeChallenge {
    let sampleImageName: String
    let targetValues: [GradingParameterID: Float]
    let tolerance: Float
}

extension PracticeChallenge {
    static let current = PracticeChallenge(
        sampleImageName: "sample_photo",
        targetValues: [
//            .vibrance: 1.2,// 0.78
//            .contrast: 0.6, // -0.97
//            .brightness: -0.4, // -0.52
//            .saturation: 0.8 // 1.65
            .vibrance: 1.75,
            .contrast: 1.8,
            .brightness: 0.9,
            .saturation: 1.5
        ],
        tolerance: 0.45
    )
}
