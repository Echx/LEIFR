//
//  LFZoomLevelTest.swift
//  LEIFR
//
//  Created by Lei Mingyu on 30/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import XCTest
@testable import LEIFR

class LFZoomLevelTest: XCTestCase {
    func testScaleToLevel() {
        let level1 = LFZoomLevel(zoomScale: MKZoomScale(0.325))
        let level2 = LFZoomLevel(zoomScale: MKZoomScale(0.021412))
        let level3 = LFZoomLevel(zoomScale: MKZoomScale(0.1))
        let level4 = LFZoomLevel(zoomScale: MKZoomScale(0.000001))
        
        XCTAssertEqual(level1.zoomLevel, 18)
        XCTAssertEqual(level2.zoomLevel, 14)
        XCTAssertEqual(level3.zoomLevel, 16)
        XCTAssertEqual(level4.zoomLevel, 0)
    }
}
