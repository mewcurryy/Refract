//
//  ShareContentBuilderTests.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import XCTest
@testable import Refract

final class ShareContentBuilderTests: XCTestCase {
    func test_buildCompletionMessage_brightness_includeModuleTitle() {
        let message = ShareContentBuilder.buildCompletionMessage(for: GradingParameterCatalog.brightnessModule)
        XCTAssertTrue(message.contains("Brightness"))
    }
    
    func test_buildCompletionMessage_contrast_includeModuleTitle() {
        let message = ShareContentBuilder.buildCompletionMessage(for: GradingParameterCatalog.contrastModule)
        XCTAssertTrue(message.contains("Contrast"))
    }
    
    func test_buildCompletionMessage_saturation_includeModuleTitle() {
        let message = ShareContentBuilder.buildCompletionMessage(for: GradingParameterCatalog.saturationModule)
        XCTAssertTrue(message.contains("Saturation"))
    }
    
    func test_buildCompletionMessage_vibrance_includeModuleTitle() {
        let message = ShareContentBuilder.buildCompletionMessage(for: GradingParameterCatalog.vibranceModule)
        XCTAssertTrue(message.contains("Vibrance"))
    }
}
