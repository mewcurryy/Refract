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
    

    private let targetTolerance: Float = 0.4
    
    private(set) var currentSliderValue: Float // private set gunanya agar bisa di-read dari luar tapi write tetap di dalam file ini
    
    private(set) var hasHitFirstTarget = false
    private(set) var hasHitSecondTarget = false
    private(set) var isExplanationRevealed = false
    
    var isModuleCompleted: Bool { progressStore.isComplete(paramsInfo.id) }
    var onCompletedBadgeVisibilityChanged: ((Bool) -> Void)?
    
    var currentIndex: Int {
        allModules.firstIndex(where: {$0.id == paramsInfo.id}) ?? 0
    }
    
    var totalModules: Int {allModules.count}
    var positionLabel: String {"Module \(currentIndex+1) of \(totalModules)"}
    var progressFraction: Double {Double(progressStore.completedCount)/Double(totalModules)} // misal complete 2/4 Module harus Double karena kalo Int dia bakal jadi 0%, padahal harusnya 50%
    var upcomingModules: [GradingParameter] {allModules.filter{$0.id != paramsInfo.id && !progressStore.isComplete($0.id)}}
    
    var onProgressUpdated: (() -> Void)?
    var onPreviewUpdated: ((UIImage?) -> Void)?
    var onValueLabelUpdated: ((String) -> Void)?
    var onShareButtonVisibilityChanged: ((Bool) -> Void)?
    var onExtremePreviewsReady: ((UIImage?, UIImage?) -> Void)?
    
    // titik pertama/kedua di slider udah kena apa belum -> buat toggle icon checkmark di marker
    var onTargetHitStatusChanged: ((_ first: Bool, _ second: Bool) -> Void)?
    // dipanggil PERSIS SEKALI ketika kedua titik udah kena -> trigger UI nampilin penjelasan dengan animasi
    var onExplanationRevealed: ((_ title: String, _ body: String) -> Void)?
    
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
        
        let alreadyComplete = progressStore.isComplete(paramsInfo.id)
        onCompletedBadgeVisibilityChanged?(alreadyComplete)
        onShareButtonVisibilityChanged?(alreadyComplete)

        if alreadyComplete {
            hasHitFirstTarget = true
            hasHitSecondTarget = true
            isExplanationRevealed = true
            onTargetHitStatusChanged?(true, true)
            onExplanationRevealed?(paramsInfo.explanationTitle, paramsInfo.explanationBody)
        }
    }
    
    func sliderDidChange(to value: Float) {
        currentSliderValue = value
        updatePreview(sliderValue: value)
        checkTryThisTargets(value: value)
    }
    
    // cek apakah posisi slider sekarang "kena" salah satu/kedua titik TRY THIS. Sekali kena, status
    // tetap true walau slider digeser lagi ke tempat lain (ga perlu pas di titik itu terus).
    private func checkTryThisTargets(value: Float) {
        var didChange = false
        
        if !hasHitFirstTarget && abs(value - paramsInfo.tryThisLowTarget) <= targetTolerance {
            hasHitFirstTarget = true
            didChange = true
        }
        if !hasHitSecondTarget && abs(value - paramsInfo.tryThisHighTarget) <= targetTolerance {
            hasHitSecondTarget = true
            didChange = true
        }
        
        guard didChange else { return }
        onTargetHitStatusChanged?(hasHitFirstTarget, hasHitSecondTarget)
        
        if hasHitFirstTarget && hasHitSecondTarget && !isExplanationRevealed {
            isExplanationRevealed = true
            onExplanationRevealed?(paramsInfo.explanationTitle, paramsInfo.explanationBody)
        }
    }

    func markAsComplete() {
        guard isExplanationRevealed else { return }
        progressStore.markComplete(paramsInfo.id)
        onCompletedBadgeVisibilityChanged?(true)
        onShareButtonVisibilityChanged?(true)
        onProgressUpdated?() // notify progress untuk berubah
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
    
    private func prepareExtremePreviews() {
        guard let ciImage = CIImage(image: sampleImage) else {return}
        let low = engine.applyGrading(to: ciImage, values: [paramsInfo.id: paramsInfo.sliderRange.lowerBound])
        let high = engine.applyGrading(to: ciImage, values: [paramsInfo.id: paramsInfo.sliderRange.upperBound])
        onExtremePreviewsReady?(engine.renderToImage(low), engine.renderToImage(high))
    }

    // debug function
    func resetCompletionState() {
        hasHitFirstTarget = false
        hasHitSecondTarget = false
        isExplanationRevealed = false
        currentSliderValue = paramsInfo.defaultSliderValue
        
        onTargetHitStatusChanged?(false, false)
        onShareButtonVisibilityChanged?(false)
        onCompletedBadgeVisibilityChanged?(false)
        updatePreview(sliderValue: currentSliderValue)
        prepareExtremePreviews()
    }
    
    func refreshFromStore() {
        let isDone = progressStore.isComplete(paramsInfo.id)
        onCompletedBadgeVisibilityChanged?(isDone)
        onShareButtonVisibilityChanged?(isDone)
        onProgressUpdated?()
    }
}
