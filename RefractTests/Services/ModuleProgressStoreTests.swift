//
//  ModuleProgressStoreTests.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import XCTest
@testable import Refract

final class ModuleProgressStoreTests: XCTestCase {
    
    private var testDefaults: UserDefaults!
    private var testStore: ModuleProgressStore!
    
    override func setUp() {
        super.setUp()
        // suitenya terpisah setiap test biar ga numpuk
        testDefaults = UserDefaults(suiteName: #file) // #file -> compiler directive, auto replace jadi string path file ini sendiri
        testDefaults.removePersistentDomain(forName: #file) // kosongin suite
        testStore = ModuleProgressStore(defaults: testDefaults)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: #file)
        testStore = nil
        testDefaults = nil
        super.tearDown()
    }
    
    func test_isComplete_isFalse_forFreshStore() {
        XCTAssertFalse(testStore.isComplete(.brightness))
    }
    
    func test_isComplete_isTrue() {
        testStore.markComplete(.brightness)
        XCTAssertTrue(testStore.isComplete(.brightness))
    }
    
    func test_isComplete_isNotAffectOtherModules() {
        testStore.markComplete(.brightness)
        XCTAssertFalse(testStore.isComplete(.contrast))
    }
    
    func test_markComplete_isNotChangingWhenRestart() { // test kalo app di restart (progress TIDAK AKAN BERUBAH)
        testStore.markComplete(.vibrance)
        let reloadedStore = ModuleProgressStore(defaults: testDefaults)
        XCTAssertTrue(reloadedStore.isComplete(.vibrance))
    }
    
    func test_onProgressChanged_onlyOnceMarkComplete() {
        var callCount = 0
        testStore.onProgressChanged = {callCount += 1}
        testStore.markComplete(.contrast)
        testStore.markComplete(.contrast)
        XCTAssertEqual(callCount, 1) // setiap module cuma sekali bisa markComplete jadi harusnya onProgressChanged cuma di-call sekali
    }
}
