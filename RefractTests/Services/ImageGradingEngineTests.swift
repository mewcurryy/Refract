//
//  ImageGradingEngineTests.swift
//  Refract
//
//  Created by Davin P on 03/09/26.
//

import XCTest
import CoreImage
@testable import Refract

final class ImageGradingEngineTests: XCTestCase {

    var engine: ImageGradingEngine! // make sure ada nilainya sebelum dijalanin (sebenernya bisa nil juga) to avoid explicit handling, tapi kalau ada nil app akan crash total

    override func setUp() { // dipanggil otomatis sebelum tiap test method jalan, setUp bakal dipanggil (refresh engine)
        super.setUp()
        engine = ImageGradingEngine()
    }

    override func tearDown() { // memory cleanup -> engine = nil (ga penting" banget), dipanggil otomatis setelah tiap test method jalan
        engine = nil
        super.tearDown()
    }

    private func makeSampleImage() -> CIImage {
        CIImage(color: .red).cropped(to: CGRect(x: 0, y: 0, width: 20, height: 20)) // kotak 20x20 dari titik 0,0
    }

    func test_applyGrading_neutralValue_returnsNonEmptyImage() {
        let result = engine.applyGrading(to: makeSampleImage(), values: [.brightness: 0, .contrast: 0, .saturation: 0, .vibrance: 0])
        XCTAssertFalse(result.extent.isEmpty) // pastikan hasil ga kosong, kalau kosong ada false
    }

    func test_applyGrading_withEmptyValues_defaultsToNeutralWithoutCrash() {
        let result = engine.applyGrading(to: makeSampleImage(), values: [:]) // tidak ada parameter yang dikirim
        XCTAssertFalse(result.extent.isEmpty)
    }

    func test_renderToImage_producesValidUIImage() {
        let graded = engine.applyGrading(to: makeSampleImage(), values: [.brightness: 0.3])
        XCTAssertNotNil(engine.renderToImage(graded))
    }
}
