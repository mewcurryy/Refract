//
//  PracticeModeViewModel.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import UIKit
import CoreImage

final class PracticeModeViewModel {
    private let gradingEngine: ImageGradingEngine
    private let histogramAnalyzer: HistogramAnalyzing
    
    private var importedCIImage: CIImage?
    private(set) var currentValues: [GradingParameterID : Float] = [:]
    private(set) var feedbackMessages: [FeedbackMessage] = []
    private var regradeWorkItem: DispatchWorkItem?
    
    var onPreviewUpdated: ((UIImage?) -> Void)?
    var onFeedbackUpdated: (([FeedbackMessage]) -> Void)?
    var hasImportedImage: Bool { // apakah user import foto atau belum
        importedCIImage != nil
    }
    
    init(
        gradingEngine: ImageGradingEngine = ImageGradingEngine(),
        histogramAnalyzer: HistogramAnalyzing = RealHistogramAnalyzer()
    ){
        self.gradingEngine = gradingEngine
        self.histogramAnalyzer = histogramAnalyzer
    }
    
    func imagePicked(_ image: UIImage) { // user pilih foto baru
        importedCIImage = CIImage(image: image)
        currentValues = [:]
        regradeAndAnalyze()
    }
    
    func sliderDidChange(parameter: GradingParameterID, value: Float) { // kalau user geser slider
        currentValues[parameter] = value
        scheduleRegrade()
    }
    
    private func scheduleRegrade() {
        regradeWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.regradeAndAnalyze()
        }
        regradeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12, execute: workItem)
    }
    
    func resetValues() {
        currentValues = [:]
        regradeAndAnalyze()
    }
    
    func value(for parameter: GradingParameterID) -> Float { // untuk ambil value dari slider
        currentValues[parameter] ?? 0
    }
    
    func submitForFeedback() {
        onFeedbackUpdated?(feedbackMessages)
    }
    private func regradeAndAnalyze() {
        guard let importedCIImage else {
            onPreviewUpdated?(nil) // ngga ada preview, kosongin saja
            return
        }
        let graded = gradingEngine.applyGrading(to: importedCIImage, values: currentValues)
        onPreviewUpdated?(gradingEngine.renderToImage(graded))
        let stats = histogramAnalyzer.analyze(original: importedCIImage, graded: graded)
        feedbackMessages = FeedbackRuleEngine.evaluate(stats)
    }
}
