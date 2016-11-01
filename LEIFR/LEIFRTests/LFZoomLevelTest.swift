//
//  LFZoomLevelTest.swift
//  LEIFR
//
//  Created by Lei Mingyu on 30/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import XCTest
@testable import LEIFR

import MapKit

class LFZoomLevelTest: XCTestCase {
    func testScaleToLevel() {
        let scale1 = MKZoomScale(0.325)
        let scale2 = MKZoomScale(0.021412)
        let scale3 = MKZoomScale(0.1)
        let scale4 = MKZoomScale(0.000001)
        
        XCTAssertEqual(scale1.toZoomLevel(), 18)
        XCTAssertEqual(scale2.toZoomLevel(), 14)
        XCTAssertEqual(scale3.toZoomLevel(), 16)
        XCTAssertEqual(scale4.toZoomLevel(), 0)
    }
}
