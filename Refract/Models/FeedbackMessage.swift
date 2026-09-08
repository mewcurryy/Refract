//
//  FeedbackMessage.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import Foundation

enum FeedbackSeverity {
    case ok
    case warning
}

struct FeedbackMessage: Equatable {
    let severity: FeedbackSeverity
    let message: String
}
