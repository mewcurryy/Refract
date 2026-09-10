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
    private let challenge: PracticeChallenge
    
    private var importedCIImage: CIImage?
    private(set) var currentValues: [GradingParameterID : Float] = [:]
    private(set) var feedbackMessages: [FeedbackMessage] = []
    private(set) var targetPreviewImage: UIImage? // gambar "target" yang harus dikejar user
    private var regradeWorkItem: DispatchWorkItem?
    
    var onPreviewUpdated: ((UIImage?) -> Void)?
    var onFeedbackUpdated: (([FeedbackMessage]) -> Void)?
    var onResultsUpdated: (([GradingParameterID: Bool], Int, Int) -> Void)?
    var onTargetPreviewUpdated: ((UIImage?) -> Void)? // dipanggil sekali tiap gambar sample baru diload
    var hasImportedImage: Bool { // apakah user import foto atau belum
        importedCIImage != nil
    }
    
    init(
        gradingEngine: ImageGradingEngine = ImageGradingEngine(),
        histogramAnalyzer: HistogramAnalyzing = RealHistogramAnalyzer(),
        challenge: PracticeChallenge = .current
    ){
        self.gradingEngine = gradingEngine
        self.histogramAnalyzer = histogramAnalyzer
        self.challenge = challenge
    }
    
    func imagePicked(_ image: UIImage) { // user pilih foto baru
        importedCIImage = CIImage(image: image)
        currentValues = [:]
        computeTargetPreview()
        regradeAndAnalyze()
    }
    
    func loadSampleImage() {
        guard let uiImage = UIImage(named: challenge.sampleImageName) else { return }
        importedCIImage = CIImage(image: uiImage)
        currentValues = [:]
        computeTargetPreview()
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
            var results: [GradingParameterID: Bool] = [:]
            var correctCount = 0
            for (parameter, target) in challenge.targetValues {
                let userValue = currentValues[parameter] ?? 0
                let isCorrect = abs(userValue - target) <= challenge.tolerance
                results[parameter] = isCorrect
                if isCorrect { correctCount += 1 }
            }
            onResultsUpdated?(results, correctCount, challenge.targetValues.count)
        }
    
    private func computeTargetPreview() {
        guard let importedCIImage else {
            targetPreviewImage = nil
            onTargetPreviewUpdated?(nil)
            return
        }
        let targetGraded = gradingEngine.applyGrading(to: importedCIImage, values: challenge.targetValues)
        targetPreviewImage = gradingEngine.renderToImage(targetGraded)
        onTargetPreviewUpdated?(targetPreviewImage)
    }
    
    private func regradeAndAnalyze() {
        guard let importedCIImage else {
            onPreviewUpdated?(nil) // ngga ada preview, kosongin saja
            return
        }
        let graded = gradingEngine.applyGrading(to: importedCIImage, values: currentValues)
        onPreviewUpdated?(gradingEngine.renderToImage(graded))
    }
}
