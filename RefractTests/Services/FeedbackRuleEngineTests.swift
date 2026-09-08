//
//  FeedbackRuleEngineTests.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import XCTest
@testable import Refract

final class FeedbackRuleEngineTests: XCTestCase {
    func test_noIssues_returnOkMessage() {
        let stats = HistogramStats(highlightClippingPercentage: 0, shadowClippingPercentage: 0, saturationDeviation: 0)
        let result = FeedbackRuleEngine.evaluate(stats)
        XCTAssertEqual(result, [FeedbackMessage(severity: .ok, message: "Exposure dan warna udah balanced, hasil grading kamu solid! 🎉")])
    }
    
    func test_highlightClipping_aboveThreshold_producesWarning() {
        let stats = HistogramStats(highlightClippingPercentage: 0.15, shadowClippingPercentage: 0, saturationDeviation: 0)
        let result = FeedbackRuleEngine.evaluate(stats)
        XCTAssertEqual(result.count, 1) // 1 array
        XCTAssertEqual(result[0].severity, .warning)
        XCTAssertTrue(result[0].message.contains("15%"))
    }
    
    func test_highlightClipping_exactlyAtThreshold_doesNotTrigger() {
        let stats = HistogramStats(highlightClippingPercentage: FeedbackRuleEngine.highlightClippingThreshold, shadowClippingPercentage: 0, saturationDeviation: 0)
        let result = FeedbackRuleEngine.evaluate(stats)
        XCTAssertEqual(result, [FeedbackMessage(severity: .ok, message: "Exposure dan warna udah balanced, hasil grading kamu solid! 🎉")])
    }
    
    func test_shadowClipping_aboveThreshold_producesWarning() {
        let stats = HistogramStats(highlightClippingPercentage: 0, shadowClippingPercentage: 0.5, saturationDeviation: 0)
        let result = FeedbackRuleEngine.evaluate(stats)
        XCTAssertTrue(result.contains {$0.message.contains("pure black")})
    }
    
    func test_saturationTooHigh_producesOversaturatedWarning() {
        let stats = HistogramStats(highlightClippingPercentage: 0, shadowClippingPercentage: 0, saturationDeviation: 0.5)
        let result = FeedbackRuleEngine.evaluate(stats)
        XCTAssertTrue(result.contains {$0.message.contains("norak")})
    }
    
    func test_saturationTooLow_producesDesaturatedWarning() {
        let stats = HistogramStats(highlightClippingPercentage: 0, shadowClippingPercentage: 0, saturationDeviation: -0.5)
        let result = FeedbackRuleEngine.evaluate(stats)
        XCTAssertTrue(result.contains {$0.message.contains("pucat")})
    }
    
    func test_multipleIssuesAtOnce_producesMultipleMessages() {
        let stats = HistogramStats(highlightClippingPercentage: 0.15, shadowClippingPercentage: 0.15, saturationDeviation: 0.5)
        let result = FeedbackRuleEngine.evaluate(stats)
        XCTAssertEqual(result.count, 3)
    }
}
