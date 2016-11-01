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
    
    fileprivate let databaseManager = LFDatabaseManager.shared
    
    override func setUp() {
        super.setUp()
        _ = self.databaseManager.createDatabase("testGeoRecordManager")
        _ = self.databaseManager.openDatabase()
    }
    
    override func tearDown() {
        _ = self.databaseManager.closeDatabase()
        _ = self.databaseManager.removeDatabase("testGeoRecordManager")
        super.tearDown()
    }
    
}

