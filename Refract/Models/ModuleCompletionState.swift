//
//  ModuleCompletionState.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import Foundation

struct ModuleCompletionState {
    private(set) var hasInteractedSlider = false
    private(set) var hasViewedExtremes = false
    private(set) var hasTriedThis = false
    
    var isComplete: Bool {
        hasInteractedSlider && hasViewedExtremes && hasTriedThis
    }
    
    mutating func markSliderInteracted() {
        hasInteractedSlider = true
    }
    
    mutating func markExtremesViewed() {
        hasViewedExtremes = true
    }
    
    mutating func markTriedThis() {
        hasTriedThis = true
    }
 }
