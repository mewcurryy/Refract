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
    
    func test_imagePicked_withExtremeStats_produceWarning() {
        let extremeStats = HistogramStats(highlightClippingPercentage: 80.0, shadowClippingPercentage: 80.0, saturationDeviation: 0)
        let viewModel = PracticeModeViewModel(histogramAnalyzer: StubHistogramAnalyzer(stats: extremeStats)) // coba inject histogram analyzer dengan extremeStats
        viewModel.imagePicked(makeSampleImage())
        
        let expectation = XCTestExpectation(description: "Tunggu sampai feedback di-update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        let receivedFeedback = viewModel.feedbackMessages
        XCTAssertTrue(receivedFeedback.contains(where: { $0.severity == .warning}))
    }
    
    func test_sliderDidChange_updateCurrentValue() {
        let viewModel = PracticeModeViewModel()
        viewModel.imagePicked(makeSampleImage())
        viewModel.sliderDidChange(parameter: .brightness, value: 0.8)
        XCTAssertEqual(viewModel.value(for: .brightness), 0.8)
    }
    
    
}
