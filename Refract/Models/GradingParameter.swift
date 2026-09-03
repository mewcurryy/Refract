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

struct GradingParameter{
    let id: GradingParameterID
    let title: String // for navbar and upcoming lessons
    let cardTitle: String // for home dashboard card
    let explanation: String
    let usageTip: String
    let extremeLowLabel: String
    let extremeHighLabel: String
    let durationMinutes: Int
    let sliderRange: ClosedRange<Float> = -5.0...5.0
    let defaultSliderValue: Float = 0.0
}

enum GradingParameterCatalog{
    static let brightnessModule = GradingParameter(
        id: .brightness,
        title: "Brightness",
        cardTitle: "Brightness Tutorial 101",
        explanation: "Brightness mengatur seberapa terang atau gelap keseluruhan foto secara merata, dari bagian tergelap sampai paling terang.",
        usageTip: "Pakai brightness kalau foto kamu secara keseluruhan under-exposed atau over-exposed secara merata.",
        extremeLowLabel: "Kekecilan: foto jadi gelap gulita, detail shadow hilang total.",
        extremeHighLabel: "Kegedean: foto jadi putih pucat, detail highlight hilang.",
        durationMinutes: 5
    )
    
    static let contrastModule = GradingParameter(
        id: .contrast,
        title: "Contrast",
        cardTitle: "Contrast in Images",
        explanation: "Contrast mengatur jarak antara area gelap dan area terang di foto.",
        usageTip: "Pakai contrast buat bikin foto terasa lebih 'hidup' atau tegas.",
        extremeLowLabel: "Kekecilan: foto jadi flat/abu-abu, kurang 'nendang'.",
        extremeHighLabel: "Kegedean: shadow hitam pekat, highlight putih polos.",
        durationMinutes: 4
    )
    
    static let saturationModule = GradingParameter(
        id: .saturation,
        title: "Saturation",
        cardTitle: "Saturation Deep Dive",
        explanation: "Saturation mengatur intensitas SEMUA warna di foto secara merata.",
        usageTip: "Pakai saturation kalau warna foto terasa pucat semua, atau mau efek hitam-putih.",
        extremeLowLabel: "Kekecilan: semua warna hilang, jadi grayscale.",
        extremeHighLabel: "Kegedean: warna jadi neon/tidak natural.",
        durationMinutes: 5
    )
    
    static let vibranceModule = GradingParameter(
        id: .vibrance,
        title: "Vibrance",
        cardTitle: "Vibrance Essentials",
        explanation: "Vibrance mirip saturation, tapi lebih pintar — warna pudar dinaikkan lebih kuat, warna kulit dinaikkan lebih halus.",
        usageTip: "Pakai vibrance sebagai alternatif saturation yang lebih aman untuk foto ada orangnya.",
        extremeLowLabel: "Kekecilan: warna pudar tambah pudar.",
        extremeHighLabel: "Kegedean: warna pudar jadi berlebihan.",
        durationMinutes: 6
    )
    
    static let all: [GradingParameter] = [brightnessModule, contrastModule, saturationModule, vibranceModule]
}
