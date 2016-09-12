//
//  LFGeoRecordManagerTest.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import XCTest
@testable import LEIFR

class LFGeoRecordManagerTest: XCTestCase {
    
    private let databaseManager = LFDatabaseManager.sharedManager()
    
    override func setUp() {
        super.setUp()
        self.databaseManager.createDatabase("testGeoRecordManager")
        self.databaseManager.openDatabase()
    }
    
    override func tearDown() {
        self.databaseManager.closeDatabase()
        self.databaseManager.removeDatabase("testGeoRecordManager")
        super.tearDown()
    }
    
}

