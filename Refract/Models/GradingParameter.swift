//
//  GradingParameter.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import Foundation

enum GradingParameterID: String, CaseIterable {
    case brightness
    case contrast
    case saturation
    case vibrance
}

struct GradingParameter {
    let id: GradingParameterID
    let title: String // for navbar and upcoming lessons
    let cardTitle: String // for home dashboard card
    let explanationTitle: String // judul di explanation card, muncul setelah kedua TRY THIS target kena
    let explanationBody: String // isi penjelasan di explanation card
    let usageTip: String
    let extremeLowLabel: String
    let extremeHighLabel: String
    let durationMinutes: Int
    let tryThisLowTarget: Float // titik pertama yang harus dikenain slider
    let tryThisHighTarget: Float // titik kedua yang harus dikenain slider
    let sliderRange: ClosedRange<Float> = -5.0...5.0
    let defaultSliderValue: Float = 0.0
}

enum GradingParameterCatalog {
    static let brightnessModule = GradingParameter(
        id: .brightness,
        title: "Brightness",
        cardTitle: "Brightness Tutorial 101",
        explanationTitle: "Why Is Brightness Important?",
        explanationBody: "Brightness adjusts the overall lightness or darkness of the photo uniformly, from the darkest areas to the brightest.",
        usageTip: "Use brightness if your photo is uniformly underexposed or overexposed.",
        extremeLowLabel: "Too low: photo becomes pitch black; shadow detail is completely lost.",
        extremeHighLabel: "Too high: photo becomes washed out; highlight detail is lost.",
        durationMinutes: 5,
        tryThisLowTarget: -3.0,
        tryThisHighTarget: 3.0
    )
    
    static let contrastModule = GradingParameter(
        id: .contrast,
        title: "Contrast",
        cardTitle: "Contrast in Images",
        explanationTitle: "Why Is Contrast Important?",
        explanationBody: "Contrast adjusts the range between dark and light areas in the photo.",
        usageTip: "Use contrast to make the photo feel more 'vivid' or defined.",
        extremeLowLabel: "Too low: photo looks flat/gray; lacks 'punch'.",
        extremeHighLabel: "Too high: shadows become pitch black; highlights become pure white.",
        durationMinutes: 4,
        tryThisLowTarget: -3.0,
        tryThisHighTarget: 3.0
    )
    
    static let saturationModule = GradingParameter(
        id: .saturation,
        title: "Saturation",
        cardTitle: "Saturation Deep Dive",
        explanationTitle: "Why Is Saturation Important?",
        explanationBody: "Saturation adjusts the intensity of ALL colors in the photo uniformly.",
        usageTip: "Use saturation if the photo's colors look washed out, or if you want a black-and-white effect.",
        extremeLowLabel: "Too low: all color is lost; becomes grayscale.",
        extremeHighLabel: "Too high: colors become neon or unnatural.",
        durationMinutes: 5,
        tryThisLowTarget: -3.0,
        tryThisHighTarget: 3.0
    )
    
    static let vibranceModule = GradingParameter(
        id: .vibrance,
        title: "Vibrance",
        cardTitle: "Vibrance Essentials",
        explanationTitle: "Why is Vibrance Important?",
        explanationBody: "Vibrance is similar to saturation but smarter—it boosts muted colors more strongly while enhancing skin tones more subtly.",
        usageTip: "Use vibrance as a safer alternative to saturation for photos featuring people.",
        extremeLowLabel: "Too low: muted colors become even more muted.",
        extremeHighLabel: "Too high: muted colors become exaggerated.",
        durationMinutes: 6,
        tryThisLowTarget: -3.0,
        tryThisHighTarget: 3.0
    )
    
    static let all: [GradingParameter] = [brightnessModule, contrastModule, saturationModule, vibranceModule]
}
