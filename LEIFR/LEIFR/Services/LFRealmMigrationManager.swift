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
    public func migrate(path: NSURL) {
        let realm = try!Realm(path)
    }
}
