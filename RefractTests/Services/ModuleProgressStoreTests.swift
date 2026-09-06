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
    private var store: ModuleProgressStore!
    
    override func setUp() {
        super.setUp()
        // suitenya terpisah setiap test biar ga numpuk
        testDefaults = UserDefaults(suiteName: #file) // #file -> compiler directive, auto replace jadi string path file ini sendiri
        testDefaults.removePersistentDomain(forName: #file) // kosongin suite
        store = ModuleProgressStore(defaults: testDefaults)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: #file)
        store = nil
        testDefaults = nil
        super.tearDown()
    }
    
    func test_isComplete_isFalse_forFreshStore() {
        XCTAssertFalse(store.isComplete(.brightness))
    }
    
    func test_isComplete_isTrue() {
        store.markComplete(.brightness)
        XCTAssertTrue(store.isComplete(.brightness))
    }
    
    func test_isComplete_isNotAffectOtherModules() {
        store.markComplete(.brightness)
        XCTAssertFalse(store.isComplete(.contrast))
    }
    
    func test_markComplete_isNotChangingWhenRestart() { // test kalo app di restart (progress TIDAK AKAN BERUBAH)
        store.markComplete(.vibrance)
        let reloadedStore = ModuleProgressStore(defaults: testDefaults)
        XCTAssertTrue(reloadedStore.isComplete(.vibrance))
    }
    
    func test_onProgressChanged_onlyOnceMarkComplete() {
        var callCount = 0
        store.onProgressChanged = {callCount += 1}
        store.markComplete(.contrast)
        store.markComplete(.contrast)
        XCTAssertEqual(callCount, 1) // setiap module cuma sekali bisa markComplete jadi harusnya onProgressChanged cuma di-call sekali
    }
}
