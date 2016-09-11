//
//  LFPath.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFPath: NSObject {
	private let lineString: WKBLineString
	
	init(lineString: WKBLineString) {
		self.lineString = lineString
		super.init()
	}
	
	override init() {
		self.lineString = WKBLineString(hasZ: true, andHasM: true)
		super.init()
	}
	
	func addPoint(latitude latitude: Double, longitude: Double, altitude: Double) {
		addPoint(latitude: latitude, longitude: longitude, altitude: altitude, time: NSDate())
	}
	
	func addPoint(latitude latitude: Double, longitude: Double, altitude: Double, time: NSDate) {
		let point = WKBPoint(hasZ: true, andHasM: true, andX: NSDecimalNumber(double: longitude), andY: NSDecimalNumber(double: latitude))
		point.z = NSDecimalNumber(double: altitude)
		point.m = NSDecimalNumber(double: time.timeIntervalSince1970)
		lineString.addPoint(point)
	}
	
	func points() -> NSMutableArray {
		return lineString.points
	}
	
	func WKTString() -> String{
		let array = NSMutableArray()
		for point in lineString.points {
			array.addObject("\(point.x as NSDecimalNumber) \(point.y as NSDecimalNumber) \(point.z as NSDecimalNumber) \(point.m as NSDecimalNumber)")
		}
		
		let pointsString = array.componentsJoinedByString(", ")
		return "LINESTRINGZM(" + pointsString + ")"
	}
}

extension WKBPoint {
	var latitude: Double {
		get {
			return Double(self.y)
		}
	}
	
	var longitude: Double {
		get {
			return Double(self.x)
		}
	}
	
	var altitude: Double {
		get {
			return Double(self.z)
		}
	}
	
	var time:NSDate {
		get {
			return NSDate(timeIntervalSince1970: Double(self.m))
		}
	}
}