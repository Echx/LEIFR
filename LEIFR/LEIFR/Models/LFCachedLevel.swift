//
//  LFCachedLevel.swift
//  LEIFR
//
//  Created by Lei Mingyu on 29/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import RealmSwift

class LFCachedLevel: Object {
    @objc dynamic var level = 0
    @objc dynamic var lastModified = NSDate()
    let points = List<LFCachedPoint>()
    
    override static func primaryKey() -> String? {
        return "level"
    }
}
