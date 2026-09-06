//
//  ModuleProgressStore.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

// tujuannya untuk penghubung antara home dan detail, untuk track module mana yang udah selesai dan disimpan biar ga hilang ketika restart

import Foundation

final class ModuleProgressStore {
    static let shared = ModuleProgressStore() // dibuat sekali seumur hidup
    
    private let defaultsKey = "completeModuleIDs"
    private let defaults: UserDefaults // biar ga ngotorin testing
    
    private(set) var completeIDs: Set<GradingParameterID> // lebih cepet dari array, makanya pake Set
    
    var onProgressChanged: (() -> Void)? // untuk tahu kapan progress berubah
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let savedRawValues = defaults.stringArray(forKey: defaultsKey) ?? [] // baca data lama. kalo kosong, ganti sama array kosong
        self.completeIDs = Set(savedRawValues.compactMap({GradingParameterID(rawValue: $0)})) // dari enum GradingParameterID jadi string
    }
    
    func isComplete(_ id: GradingParameterID) -> Bool { // check module status
        completeIDs.contains(id)
    }
    
    func markComplete(_ id: GradingParameterID) {
        guard !completeIDs.contains(id) else { return } // kalau module udah pernah complete, ga di mark complete lagi
        completeIDs.insert(id)
        persist()
        onProgressChanged?()
    }
    
    private func persist() {
        defaults.set(completeIDs.map(\.rawValue), forKey: defaultsKey) // simpan array of string ke UserDefault
    }
    
    var completedCount: Int { // case yang complete
        completeIDs.count
    }
    
    var totalCount: Int { // total case
        GradingParameterID.allCases.count
    }
}
