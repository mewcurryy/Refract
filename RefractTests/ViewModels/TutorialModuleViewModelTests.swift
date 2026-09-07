//
//  TutorialModuleViewModelTests.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import XCTest
@testable import Refract

final class TutorialModuleViewModelTests: XCTestCase {
    private var testDefaults: UserDefaults!
    private var testStore: ModuleProgressStore!
    
    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: #file)
        testDefaults.removePersistentDomain(forName: #file)
        testStore = ModuleProgressStore(defaults: testDefaults)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: #file)
        testStore = nil
        testDefaults = nil
        super.tearDown()
    }
    
    private func makeSampleImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }
    
    private func makeViewModel(for parameter: GradingParameter = GradingParameterCatalog.brightnessModule) -> TutorialModuleViewModel {
        TutorialModuleViewModel(paramsInfo: parameter, sampleImage: makeSampleImage(), progressStore: testStore)
    }
    
    func test_positionLabel_correctIndex() {
        let viewModel = makeViewModel(for: GradingParameterCatalog.contrastModule)
        XCTAssertEqual(viewModel.positionLabel, "Module 2 of 4")
        XCTAssertEqual(viewModel.totalModules, 4)
    }
    
    func test_upcomingModules_excludesCurrentAndCompletedModules() {
        let currentModule = GradingParameterCatalog.brightnessModule
        let completedModule = GradingParameterCatalog.saturationModule
        
        testStore.markComplete(completedModule.id) // anggap saturation done
        let viewModel = makeViewModel(for: currentModule)
        let upcomingIDs = viewModel.upcomingModules.map(\.id)
        
        XCTAssertFalse(upcomingIDs.contains(currentModule.id), "Upcoming modules shouldn't contain the current module")
        XCTAssertFalse(upcomingIDs.contains(completedModule.id), "Upcoming modules shouldn't contain already completed modules")
        XCTAssertEqual(upcomingIDs.count, viewModel.totalModules - 2)
    }
    
    func test_isModuleComplete_becomesTrue_afterFullSequence() { // cek apakah module complete setelah ketiga itu dilakukan
        let viewModel = makeViewModel()
        viewModel.viewDidLoad()
        viewModel.sliderDidChange(to: 0.3)
        viewModel.tryThisTapped()
        XCTAssertTrue(viewModel.isModuleCompleted)
    }
    
    func test_completingModule_markCompleteInProgressStore() {
        let viewModel = makeViewModel(for: GradingParameterCatalog.brightnessModule)
        viewModel.viewDidLoad()
        viewModel.sliderDidChange(to: 0.3)
        viewModel.tryThisTapped()
        XCTAssertTrue(testStore.isComplete(viewModel.paramsInfo.id))
    }
    
    func test_makeDetailViewModel_sharesTheSameProgressStore() {
        let viewModel = makeViewModel(for: GradingParameterCatalog.brightnessModule)
        let nextViewModel = viewModel.makeDetailViewModel(for: GradingParameterCatalog.contrastModule)
        
        nextViewModel.viewDidLoad()
        nextViewModel.sliderDidChange(to: 0.2)
        nextViewModel.tryThisTapped()
        
        XCTAssertTrue(testStore.isComplete(nextViewModel.paramsInfo.id))
    }
}
