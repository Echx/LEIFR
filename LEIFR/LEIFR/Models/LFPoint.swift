//
//  LFPoint.swift
//  LEIFR
//
//  Created by Jinghan Wang on 8/2/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import wkb_ios

class LFPoint: NSObject {
	
	var latitude: Double = 0
	var longitude: Double = 0
	var altitude: Double = 0
	var time: Date = Date()
	
	var x: Double {
		get {
			return longitude
		}
	}
	
	var y: Double {
		get {
			return latitude
		}
	}
	
	var z: Double {
		get {
			return altitude
		}
	}
	
	var m: Double {
		get {
			return time.timeIntervalSince1970
		}
	}
	
	var coordinate: CLLocationCoordinate2D {
		get {
			return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
		}
	}
	
	var wkbPoint: WKBPoint {
		get {
			let point = WKBPoint(hasZ: true, andHasM: true, andX: NSDecimalNumber(value: longitude as Double), andY: NSDecimalNumber(value: latitude as Double))!
			point.z = NSDecimalNumber(value: altitude as Double)
			point.m = NSDecimalNumber(value: time.timeIntervalSince1970 as Double)
			return point
		}
	}
	
	override init() {
		super.init()
	}
	
	init(wkbPoint: WKBPoint) {
		super.init()
		
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
}
