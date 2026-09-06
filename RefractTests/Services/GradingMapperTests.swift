//
//  GradingMapperTests.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import XCTest
@testable import Refract

final class GradingMapperTests: XCTestCase {
    
    // MARK: - Neutral (slider at 0)
    
    func test_brightness_neutral_zero() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 0.0, params: .brightness), 0.0)
    }
    
    func test_contrast_neutral_one() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 0.0, params: .contrast), 1.0)
    }
    
    func test_saturation_neutral_one() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 0.0, params: .saturation), 1.0)
    }
    
    func test_vibrance_neutral_zero() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 0.0, params: .vibrance), 0.0)
    }
    
    // MARK: - Extreme Cases
    
    func test_contrast_extreme() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: -5.0, params: .contrast), 0.0)
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 5.0, params: .contrast), 2.0)
    }
    
    func test_saturation_extreme() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: -5.0, params: .saturation), 0.0)
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 5.0, params: .saturation), 2.0)
    }
    
    func test_brightness_extreme() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: -5.0, params: .brightness), -1.0)
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 5.0, params: .brightness), 1.0)
    }
    
    func test_vibrance_extreme_one() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 5.0, params: .vibrance), 1.0)
    }
    
    // MARK: - Halfway (proportional)
    
    func test_vibrance_halfway_proportional() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 2.5, params: .vibrance), 0.5)
    }
    
    func test_contrast_halfway_proportional() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 2.5, params: .contrast), 1.5)
    }
    
    func test_saturation_halfway_proportional() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: 2.5, params: .saturation), 1.5)
    }
    
    func test_brightness_negativeHalfway_proportional() {
        XCTAssertEqual(GradingMapper.mapFilterValue(sliderValue: -2.5, params: .brightness), -0.5)
    }
}
