//
//  TutorialModuleViewModel.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit
import CoreImage

final class TutorialModuleViewModel {
    let paramsInfo: GradingParameter
    private let sampleImage: UIImage
    private let engine: ImageGradingEngine
    private let progressStore: ModuleProgressStore
    private let allModules: [GradingParameter]
    
    private var completionState: ModuleCompletionState = ModuleCompletionState()
    private(set) var currentSliderValue: Float // private set gunanya agar bisa di-read dari luar tapi write tetap di dalam file ini
    
    var isModuleCompleted: Bool { completionState.isComplete }
    
    var currentIndex: Int {
        allModules.firstIndex(where: {$0.id == paramsInfo.id}) ?? 0
    }
    
    var totalModules: Int {allModules.count}
    var positionLabel: String {"Module \(currentIndex+1) of \(totalModules)"}
    var progressFraction: Double {Double(progressStore.completedCount)/Double(totalModules)} // misal complete 2/4 Module harus Double karena kalo Int dia bakal jadi 0%, padahal harusnya 50%
    var upcomingModules: [GradingParameter] {allModules.filter{$0.id != paramsInfo.id && !progressStore.isComplete($0.id)}}
    
    var onPreviewUpdated: ((UIImage?) -> Void)?
    var onValueLabelUpdated: ((String) -> Void)?
    var onShareButtonVisibilityChanged: ((Bool) -> Void)?
    var onExtremePreviewsReady: ((UIImage?, UIImage?) -> Void)?
    
    init(
        paramsInfo: GradingParameter,
        sampleImage: UIImage,
        engine: ImageGradingEngine = ImageGradingEngine(),
        progressStore: ModuleProgressStore = .shared,
        allModules: [GradingParameter] = GradingParameterCatalog.all
    ){
        self.paramsInfo = paramsInfo
        self.sampleImage = sampleImage
        self.engine = engine
        self.progressStore = progressStore
        self.allModules = allModules
        self.currentSliderValue = paramsInfo.defaultSliderValue // initialize param default 0.0
    }
    
    func viewDidLoad() {
        updatePreview(sliderValue: currentSliderValue)
        prepareExtremePreviews()
    }
    
    func sliderDidChange(to value: Float) {
        currentSliderValue = value
        updatePreview(sliderValue: value)
        completionState.markSliderInteracted()
        evaluateCompletion()
    }
    
    @discardableResult // boleh return value ini ga dipake valuenya
    func tryThisTapped() -> Float {
        let target = paramsInfo.sliderRange.upperBound * 0.7
        currentSliderValue = target
        updatePreview(sliderValue: target)
        completionState.markTriedThis()
        evaluateCompletion()
        return target
    }
    
    func buildShareItems(extremeHighImage: UIImage?) -> [Any] {
        var items: [Any] = [ShareContentBuilder.buildCompletionMessage(for: paramsInfo)] // return [Any] karena nerima String & UIImage sekaligus
        if let extremeHighImage { // kalau extremeImage ga nil, tambahin ke array items
            items.append(extremeHighImage)
        }
        return items
    }
    
    func makeDetailViewModel(for module: GradingParameter) -> TutorialModuleViewModel { // bikin ViewModel baru buat module selanjutnya
        TutorialModuleViewModel(paramsInfo: module, sampleImage: sampleImage, engine: engine, progressStore: progressStore, allModules: allModules)
    }
    
    private func updatePreview(sliderValue: Float) {
        onValueLabelUpdated?(String(format: "%.2f", sliderValue))
        guard let ciImage = CIImage(image: sampleImage) else {return}
        let graded = engine.applyGrading(to: ciImage, values: [paramsInfo.id: sliderValue])
        onPreviewUpdated?(engine.renderToImage(graded)) // berarti nampilin image yang setelah digraded
    }
    
    private func evaluateCompletion() {
        onShareButtonVisibilityChanged?(completionState.isComplete) // kalau onsharebutton ke trigger, kasih tau completion state udah complete
        if completionState.isComplete {
            progressStore.markComplete(paramsInfo.id)
        }
    }
    
    private func prepareExtremePreviews() {
        guard let ciImage = CIImage(image: sampleImage) else {return}
        let low = engine.applyGrading(to: ciImage, values: [paramsInfo.id: paramsInfo.sliderRange.lowerBound])
        let high = engine.applyGrading(to: ciImage, values: [paramsInfo.id: paramsInfo.sliderRange.upperBound])
        onExtremePreviewsReady?(engine.renderToImage(low), engine.renderToImage(high))
        completionState.markExtremesViewed()
        evaluateCompletion()
    }
}
