//
//  LFDatabaseManagerTest.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import XCTest
@testable import LEIFR

class LFDatabaseManagerTest: XCTestCase {
	
	private let databaseManager = LFDatabaseManager.sharedManager()
	
    override func setUp() {
        super.setUp()
		self.databaseManager.createDatabase("test")
		self.databaseManager.openDatabase()
    }
    
    override func tearDown() {
		self.databaseManager.closeDatabase()
		self.databaseManager.removeDatabase("test")
        super.tearDown()
    }
    
    func testDatabaseCreationDeletion() {
		print("")
		
		let fileManager = NSFileManager.defaultManager()
		let destinationPath = databaseManager.databasePathWithName("test")
		
		print("Database Path: \(destinationPath)\n")
		
		XCTAssertTrue(self.databaseManager.removeDatabase("testCreation"), "Failed to execute removeDatabase")
		XCTAssertFalse(fileManager.fileExistsAtPath(destinationPath), "Database not deleted")
		
		XCTAssertTrue(self.databaseManager.createDatabase("testCreation"), "Failed to create database")
		XCTAssertTrue(fileManager.fileExistsAtPath(destinationPath), "Database not created")
		
		XCTAssertTrue(self.databaseManager.removeDatabase("testCreation"), "Failed to delete database after completion")
		XCTAssertFalse(fileManager.fileExistsAtPath(destinationPath), "Database not created")
		
		print("\n\n--------------------------------------------------\n\n\n\n\n")
    }
	
	func testDatabaseAddingPath() {
		print("")
		
		
		let path = LFPath()
		let latitudes: [Double]	    =	[ 1,  2,  3,  4,  5,  6,  7,  8]
		let longitudes: [Double]	=	[11, 12, 13, 14, 15, 16, 17, 18]
		let altitudes: [Double]	    =	[21, 22, 23, 24, 25, 26, 27, 28]
		
		for i in 0..<latitudes.count {
			path.addPoint(latitude: latitudes[i], longitude: longitudes[i], altitude: altitudes[i])
		}
		
		var response1Arrived = false
		var timeOutDate = NSDate(timeIntervalSinceNow: 5)
		
		self.databaseManager.savePath(path, completion: {
			success in
			
			response1Arrived = true
		})
		
		while (!response1Arrived && timeOutDate.timeIntervalSinceNow > 0) {
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
		}
		
		if (!response1Arrived) {
			XCTFail("Block1 timed out")
		}
		
		var response2Arrived = false
		var response3Arrived = false
		timeOutDate = NSDate(timeIntervalSinceNow: 5)
		
		let worldRegion = MKCoordinateRegionForMapRect(MKMapRectWorld)
		let nullRegion = MKCoordinateRegionForMapRect(MKMapRectNull)
		
		self.databaseManager.getPathsInRegion(worldRegion, completion: {
			paths in
			XCTAssertEqual(paths[0].WKTString(), "LINESTRINGZM(-122.24223433999996928 37.43463237000000512 0 0, -122.03875936999999488 37.33450378999999488 0 0)", "Path not identical")
			response2Arrived = true
		})
		
		self.databaseManager.getPathsInRegion(nullRegion, completion: {
			paths in
			XCTAssertTrue(paths.count == 0, "Result contains unexpected values")
			response3Arrived = true
		})
		
		
		while ((!response1Arrived || !response2Arrived || !response3Arrived) && timeOutDate.timeIntervalSinceNow > 0) {
			CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, true)
		}
		
		if (!response1Arrived || !response2Arrived || !response3Arrived) {
			XCTFail("Block2 or Block3 timed out")
		}
		
		self.databaseManager.removeDatabase("test")
		
		print("\n\n--------------------------------------------------\n\n\n\n\n")
	}
}
