//
//  LFPath.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import wkb_ios

class LFPath: NSObject {
    fileprivate let minimumPointsPerPath = 5
	var points = [LFPoint]()
	var pointCount: Int {
		get {
			return self.points.count
		}
	}
	
	var startTime: Date? {
		get {
			return points.first?.time
		}
	}
	
	var endTime: Date? {
		get {
			return points.last?.time
		}
	}
	
	init(lineString: WKBLineString) {
		super.init()
		self.points = lineString.points.map({
			return LFPoint(wkbPoint: $0 as! WKBPoint)
		})
	}
	
	override init() {
		super.init()
	}
	
	func addPoint(latitude: Double, longitude: Double, altitude: Double) {
		addPoint(latitude: latitude, longitude: longitude, altitude: altitude, time: Date())
	}
	
	func addPoint(latitude: Double, longitude: Double, altitude: Double, time: Date) {
		let point = LFPoint()
		point.latitude = latitude
		point.longitude = longitude
		point.altitude = altitude
		point.time = time
		self.points.append(point)
	}
	
	func WKTString() -> String{
		let array = NSMutableArray()
		for point in points {
			array.add(point.description)
		}
		
		let pointsString = array.componentsJoined(by: ", ")
		return "LINESTRINGZM(" + pointsString + ")"
	}
    
    func isOverlappedWith(startDate: Date, endDate: Date) -> Bool {
        let points = self.points
		
		guard points.count > 0 else {
			return false
		}
		
        return !(self.startTime! > endDate || self.endTime! < startDate)
    }
    
    func isValidPath() -> Bool {
        return self.points.count >= minimumPointsPerPath
    }
	
	override var description: String {
		return self.WKTString()
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
	
	var time: Date {
		get {
			return Date(timeIntervalSince1970: Double(self.m))
		}
	}
}
