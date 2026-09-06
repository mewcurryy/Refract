//
//  ShareContentBuilder.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import Foundation

enum ShareContentBuilder {
    static func buildCompletionMessage(for parameter: GradingParameter) -> String {
        "I just completed the \(parameter.title) module on Refract! 📸"
    }
}
