//
//  LFCachedCountry.swift
//  LEIFR
//
//  Created by Jinghan Wang on 1/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import Foundation
import RealmSwift

class LFCachedCountry: Object {
	
	dynamic var code: String = ""
	dynamic var continentCode: String = ""
	dynamic var visited: Bool = false
	
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
