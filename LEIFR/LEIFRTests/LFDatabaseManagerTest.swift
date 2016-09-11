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
    }
    
    override func tearDown() {
		
        super.tearDown()
    }
    
    func testDatabaseCreationDeletion() {
		print("\n\n\n\n\n--------------------------------------------------")
		print("testDatabaseCreationDeletion\n\n")
		
		let fileManager = NSFileManager.defaultManager()
		let destinationPath = databaseManager.databasePathWithName("test")
		
		print("Database Path: \(destinationPath)\n")
		
		XCTAssertTrue(self.databaseManager.removeDatabase("test"), "Failed to execute removeDatabase")
		XCTAssertFalse(fileManager.fileExistsAtPath(destinationPath), "Database not deleted")
		
		XCTAssertTrue(self.databaseManager.createDatabase("test"), "Failed to create database")
		XCTAssertTrue(fileManager.fileExistsAtPath(destinationPath), "Database not created")
		
		XCTAssertTrue(self.databaseManager.removeDatabase("test"), "Failed to delete database after completion")
		XCTAssertFalse(fileManager.fileExistsAtPath(destinationPath), "Database not created")
		
		print("\n\n--------------------------------------------------")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
