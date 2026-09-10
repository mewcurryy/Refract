//
//  PracticeModeViewModelTests.swift
//  Refract
//
//  Created by Davin P on 08/09/26.
//

import XCTest
import CoreImage
@testable import Refract

final class PracticeModeViewModelTests: XCTestCase {
    
    private struct StubHistogramAnalyzer: HistogramAnalyzing {
        let stats: HistogramStats
        func analyze(original: CIImage, graded: CIImage) -> Refract.HistogramStats {
            stats // return stats diawal
        }
    }
    
    private func makeSampleImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }
    
    func test_hasImportedImage_isFalse_beforeAnyImagePicked() { // test apakah user udah import message atau belum
        let viewModel = PracticeModeViewModel()
        XCTAssertFalse(viewModel.hasImportedImage) // asumsi harus false karena user belom import apa"
    }
    
    func test_hasImportedImage_isTrue_afterImagePicked() {
        let viewModel = PracticeModeViewModel()
        viewModel.imagePicked(makeSampleImage())
        XCTAssertTrue(viewModel.hasImportedImage)
    }
    
    func test_imagePicked_showPreviewUpdateWithNonNilImage() {
        let viewModel = PracticeModeViewModel()
        var receivedImage: UIImage?
        viewModel.onPreviewUpdated = { receivedImage = $0 } // receivedImage diupdate
        viewModel.imagePicked(makeSampleImage())
        XCTAssertNotNil(receivedImage)
    }
    
    func test_submitForFeedback_withValuesFarFromTarget_producesIncorrectResults() {
        let challenge = PracticeChallenge(
            sampleImageName: "practice_sunset_coast",
            targetValues: [.vibrance: 1.2, .contrast: 0.6, .brightness: -0.4],
            tolerance: 0.5
        )
        let viewModel = PracticeModeViewModel(challenge: challenge)
        viewModel.loadSampleImage()
        
        // set slider jauh dari target biar salah
        viewModel.sliderDidChange(parameter: .vibrance, value: -5)
        viewModel.sliderDidChange(parameter: .contrast, value: -5)
        viewModel.sliderDidChange(parameter: .brightness, value: 5)
        
        let expectation = XCTestExpectation(description: "Tunggu hasil submit")
        viewModel.onResultsUpdated = { results, correctCount, total in
            XCTAssertEqual(correctCount, 0)
            XCTAssertEqual(total, 3)
            XCTAssertTrue(results.values.allSatisfy { $0 == false })
            expectation.fulfill()
        }
        
        viewModel.submitForFeedback()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_submitForFeedback_withValuesMatchingTarget_producesCorrectResults() {
        let challenge = PracticeChallenge(
            sampleImageName: "practice_sunset_coast",
            targetValues: [.vibrance: 1.2, .contrast: 0.6, .brightness: -0.4],
            tolerance: 0.5
        )
        let viewModel = PracticeModeViewModel(challenge: challenge)
        viewModel.loadSampleImage()
        
        // set slider persis di target biar benar semua
        viewModel.sliderDidChange(parameter: .vibrance, value: 1.2)
        viewModel.sliderDidChange(parameter: .contrast, value: 0.6)
        viewModel.sliderDidChange(parameter: .brightness, value: -0.4)
        
        let expectation = XCTestExpectation(description: "Tunggu hasil submit")
        viewModel.onResultsUpdated = { results, correctCount, total in
            XCTAssertEqual(correctCount, total)
            expectation.fulfill()
        }
        
        viewModel.submitForFeedback()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_sliderDidChange_updateCurrentValue() {
        let viewModel = PracticeModeViewModel()
        viewModel.imagePicked(makeSampleImage())
        viewModel.sliderDidChange(parameter: .brightness, value: 0.8)
        XCTAssertEqual(viewModel.value(for: .brightness), 0.8)
    }
    
    
}
