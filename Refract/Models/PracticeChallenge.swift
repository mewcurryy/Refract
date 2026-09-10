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
            .vibrance: 0.78,
            .contrast: -0.97,
            .brightness: -0.52,
            .saturation: 1.65
        ],
        tolerance: 0.5
    )
}
