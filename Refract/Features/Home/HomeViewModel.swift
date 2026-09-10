//
//  HomeViewModel.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit
import CoreImage

final class HomeViewModel {
    let userName: String = "Graders"
    let greetingSubtitle: String = "Let's coloring your image today!"
    
    private let progressStore: ModuleProgressStore
    private let gradingEngine: ImageGradingEngine
    private let allModules: [GradingParameter] = GradingParameterCatalog.all
    
    private var sneakPeekAfterCache: [GradingParameterID: UIImage] = [:]
    private lazy var rawSampleImage: UIImage? = UIImage(named: "sample_photo")
    
    var onProgressUpdated: (() -> Void)?
    
    init(progressStore: ModuleProgressStore = .shared, gradingEngine: ImageGradingEngine = ImageGradingEngine()) {
        self.progressStore = progressStore
        self.gradingEngine = gradingEngine
        self.progressStore.onProgressChanged = { [weak self] in
            self?.onProgressUpdated?() // UI refresh layar
        }
    }
    
    var numberOfModules: Int {allModules.count}
    
    func module(at index: Int) -> GradingParameter { // untuk ambil data GradingParameter di index ke-i
        allModules[index]
    }
    
    func isModuleComplete(at index: Int) -> Bool {
        progressStore.isComplete(allModules[index].id)
    }
    
    func isModuleComplete(id: GradingParameterID) -> Bool {
        progressStore.isComplete(id)
    }
    
    var completedModules: [GradingParameter] { // untuk complete modules di Home
        allModules.filter {progressStore.isComplete($0.id)}
    }
    
    func sneakPeekImages(for module: GradingParameter) -> (before: UIImage?, after: UIImage?) {
        guard let rawSampleImage else { return (nil, nil) }
        
        if let cachedAfter = sneakPeekAfterCache[module.id] {
            return (rawSampleImage, cachedAfter)
        }
        
        guard let ciImage = CIImage(image: rawSampleImage) else {
            return (rawSampleImage, nil)
        }
        
        let graded = gradingEngine.applyGrading(to: ciImage, values: [module.id: module.tryThisHighTarget])
        let afterImage = gradingEngine.renderToImage(graded)
        if let afterImage {
            sneakPeekAfterCache[module.id] = afterImage
        }
        return (rawSampleImage, afterImage)
    }
    
    // menampilkan module detail dari module yang dipilih
    func makeModuleDetailViewModel(at index: Int, sampleImage: UIImage) -> TutorialModuleViewModel {
        TutorialModuleViewModel(paramsInfo: allModules[index], sampleImage: sampleImage, progressStore: progressStore, allModules: allModules)
    }
    
    func makePracticeModeViewModel() -> PracticeModeViewModel {
        PracticeModeViewModel()
    }
}
