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
	
	init(wkbPoint: WKBPoint) {
		super.init()
		
		self.longitude = wkbPoint.x.doubleValue
		self.latitude = wkbPoint.y.doubleValue
		self.altitude = wkbPoint.z.doubleValue
		self.time = Date(timeIntervalSince1970: wkbPoint.m.doubleValue)
	}
	
}
