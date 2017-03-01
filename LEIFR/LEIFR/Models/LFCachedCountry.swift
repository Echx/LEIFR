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
	
	fileprivate lazy var locale: NSLocale = self.getCurrentLocale()
	
	func getCurrentLocale() -> NSLocale {
		let identifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: self.code])
		return NSLocale(localeIdentifier: identifier)
	}
	
	func twoDigitCountryCode() -> String {
		return (locale as Locale).regionCode?.lowercased() ?? ""
	}
	
	func localizedName() -> String {
		return locale.displayName(forKey: NSLocale.Key.countryCode, value: self.code) ?? "什么鬼"
	}
    
	override static func ignoredProperties() -> [String] {
		return ["locale"]
	}
	
}
