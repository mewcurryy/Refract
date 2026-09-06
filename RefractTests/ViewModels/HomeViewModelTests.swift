//
//  HomeViewModelTests.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import XCTest
@testable import Refract

final class HomeViewModelTests: XCTestCase {
    private var testDefaults: UserDefaults!
    private var testStore: ModuleProgressStore!
    private var testViewModel: HomeViewModel!
    
    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: #file)
        testDefaults.removePersistentDomain(forName: #file)
        testStore = ModuleProgressStore(defaults: testDefaults)
        testViewModel = HomeViewModel(progressStore: testStore)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: #file)
        super.tearDown()
    }
    
    func test_numberOfModules_matchesCatalog() {
        XCTAssertEqual(testViewModel.numberOfModules, GradingParameterCatalog.all.count)
    }
    
    func test_completedModules_isEmpty_whenNothingCompleted() {
        XCTAssertTrue(testViewModel.completedModules.isEmpty)
    }
    
    func test_completedModules_includeCompletedModule() {
        testStore.markComplete(.brightness)
        testStore.markComplete(.vibrance)
        XCTAssertEqual(testViewModel.completedModules.map(\.id), [.brightness, .vibrance])
    }
    
    func test_onProgressUpdated_calledWhenProgressStoreChanges() {
        var wasCalled = false
        testViewModel.onProgressUpdated = { wasCalled = true } // kalau ada progress, ubah called jadi true
        
        testStore.markComplete(.contrast)
        XCTAssertTrue(wasCalled) // wasCalled harus true karena ada markComplete -> harusnya onProgressUpdated ke trigger
    }
}
