//
//  LFPoint.swift
//  LEIFR
//
//  Created by Jinghan Wang on 8/2/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import wkb_ios

class LFPoint: NSObject, NSSecureCoding {
	
	fileprivate let ArchiveKeyPropertyLatitude = "ArchiveKeyPropertyLatitude"
	fileprivate let ArchiveKeyPropertyLongitude = "ArchiveKeyPropertyLongitude"
	fileprivate let ArchiveKeyPropertyAltitude = "ArchiveKeyPropertyAltitude"
	fileprivate let ArchiveKeyPropertyTime = "ArchiveKeyPropertyTime"
	
	var latitude: Double = 0
	var longitude: Double = 0
	var altitude: Double = 0
	var time: Date = Date()
	
	var x: Double { return longitude }
	var y: Double { return latitude }
	var z: Double { return altitude }
	var m: Double { return time.timeIntervalSince1970 }
	var coordinate: CLLocationCoordinate2D { return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)}
	
	var wkbPoint: WKBPoint {
		get {
			let point = WKBPoint(hasZ: true, andHasM: true, andX: NSDecimalNumber(value: longitude), andY: NSDecimalNumber(value: latitude))!
			point.z = NSDecimalNumber(value: altitude)
			point.m = NSDecimalNumber(value: time.timeIntervalSince1970)
			return point
		}
	}
	
	override init() {
		super.init()
	}
	
	convenience init(longitude: Double, latitude: Double, altitude: Double, time: Date) {
		self.init()
		self.longitude = longitude
		self.latitude = latitude
		self.altitude = altitude
		self.time = time
	}
	
	convenience init(wkbPoint: WKBPoint) {
		self.init()
		self.longitude = wkbPoint.x.doubleValue
		self.latitude = wkbPoint.y.doubleValue
		self.altitude = wkbPoint.z.doubleValue
		self.time = Date(timeIntervalSince1970: wkbPoint.m.doubleValue)
	}
	
	override var description: String {
		get {
			return "\(self.x) \(self.y) \(self.z) \(self.m)"
		}
	}
	
	// MARK: NSSecureCoding
	
	public required init?(coder aDecoder: NSCoder) {
		self.latitude = aDecoder.decodeDouble(forKey: ArchiveKeyPropertyLatitude)
		self.longitude = aDecoder.decodeDouble(forKey: ArchiveKeyPropertyLongitude)
		self.altitude = aDecoder.decodeDouble(forKey: ArchiveKeyPropertyAltitude)
		self.time = Date(timeIntervalSince1970: aDecoder.decodeDouble(forKey: ArchiveKeyPropertyTime))
	}
	
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(self.latitude, forKey: ArchiveKeyPropertyLatitude)
		aCoder.encode(self.longitude, forKey: ArchiveKeyPropertyLongitude)
		aCoder.encode(self.altitude, forKey: ArchiveKeyPropertyAltitude)
		aCoder.encode(self.time.timeIntervalSince1970, forKey: ArchiveKeyPropertyTime)
	}
	
	public static var supportsSecureCoding: Bool {
		return true;
	}
}
