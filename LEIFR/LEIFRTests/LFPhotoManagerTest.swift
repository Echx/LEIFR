//
//  LFPhotoManagerTest.swift
//  LEIFR
//
//  Created by Jinghan Wang on 29/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import XCTest
@testable import LEIFR

class LFPhotoManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testImageFetchCount() {
		let manager = LFPhotoManager.shared
		let fromDate = Date(timeIntervalSince1970: 0)
		let endDate = Date()
		let result = manager.fetchAssets(from: fromDate, till: endDate)
		print(result.count)
		XCTAssertTrue(result.count != 0)
    }
	
	func testImageFetchThumbnail() {
		let manager = LFPhotoManager.shared
		let fromDate = Date(timeIntervalSince1970: 0)
		let endDate = Date()
		let result = manager.fetchAssets(from: fromDate, till: endDate)
		for i in 0..<result.count {
			let asset = result[i]
			asset.thumbnail(completion: {
				result in
				if let image = result {
					XCTAssertEqual(image.size.width, 100, "width not correct")
					XCTAssertEqual(image.size.height, 100, "height not correct")
				}
			})
		}
	}
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
