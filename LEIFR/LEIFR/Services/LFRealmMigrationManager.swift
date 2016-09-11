//
//  LFRealmMigrationManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation
import RealmSwift

class LFRealmMigrationManager: NSObject {
    class func migrate(path: NSURL) {
        let config = Realm.Configuration(fileURL: path, readOnly: true)
        let realm = try! Realm(configuration: config)
        
        let points = realm.objects(RFTPoint.self).sorted("time")
        
        // TODO: use new DB api to seed to DB
    }
}
