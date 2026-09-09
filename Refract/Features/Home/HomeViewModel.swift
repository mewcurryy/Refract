//
//  HomeViewModel.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import UIKit

final class HomeViewModel {
    let userName: String = "Graders"
    let greetingSubtitle: String = "Let's coloring your image today!"
    
    private let progressStore: ModuleProgressStore
    private let allModules: [GradingParameter] = GradingParameterCatalog.all
    
    var onProgressUpdated: (() -> Void)?
    
    init(progressStore: ModuleProgressStore = .shared) {
        self.progressStore = progressStore
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
    
    var completedModules: [GradingParameter] { // untuk complete modules di Home
        allModules.filter {progressStore.isComplete($0.id)}
    }
    
    // menampilkan module detail dari module yang dipilih
    func makeModuleDetailViewModel(at index: Int, sampleImage: UIImage) -> TutorialModuleViewModel {
        TutorialModuleViewModel(paramsInfo: allModules[index], sampleImage: sampleImage, progressStore: progressStore, allModules: allModules)
    }
    
    func makePracticeModeViewModel() -> PracticeModeViewModel {
        PracticeModeViewModel()
    }
}
