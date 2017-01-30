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
	fileprivate let lineString: WKBLineString
	
	init(lineString: WKBLineString) {
		self.lineString = lineString
		super.init()
	}
	
	override init() {
		self.lineString = WKBLineString(hasZ: true, andHasM: true)
		super.init()
	}
	
	func addPoint(latitude: Double, longitude: Double, altitude: Double) {
		addPoint(latitude: latitude, longitude: longitude, altitude: altitude, time: Date())
	}
	
	func addPoint(latitude: Double, longitude: Double, altitude: Double, time: Date) {
		let point = WKBPoint(hasZ: true, andHasM: true, andX: NSDecimalNumber(value: longitude as Double), andY: NSDecimalNumber(value: latitude as Double))
		point?.z = NSDecimalNumber(value: altitude as Double)
		point?.m = NSDecimalNumber(value: time.timeIntervalSince1970 as Double)
		lineString.addPoint(point)
	}
	
	func points() -> NSMutableArray {
		return lineString.points
	}
	
	func WKTString() -> String{
		let array = NSMutableArray()
		for point in lineString.points {
			array.add("\((point as AnyObject).x as NSDecimalNumber) \((point as AnyObject).y as NSDecimalNumber) \((point as AnyObject).z as NSDecimalNumber) \((point as AnyObject).m as NSDecimalNumber)")
		}
		
		let pointsString = array.componentsJoined(by: ", ")
		return "LINESTRINGZM(" + pointsString + ")"
	}
    
    func isOverlappedWith(startDate: Date, endDate: Date) -> Bool {
        let points = self.points()
        if points.count == 0 {
            return false
        }
        
        let firstPoint = points.firstObject as! WKBPoint
        let lastPoint = points.lastObject as! WKBPoint
        return !(firstPoint.time > endDate || lastPoint.time < startDate)
        
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
