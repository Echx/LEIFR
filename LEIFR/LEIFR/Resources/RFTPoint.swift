//
//  RFTPoint.swift
//  RealmFlatTrial
//
//  Created by Jinghan Wang on 22/7/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class RFTPoint: Object {
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
	
	dynamic var longitude = 0.0
	dynamic var latitude = 0.0
	dynamic var time = NSDate()
	dynamic var visibleZoomLevel = 0
	private var tempMapPoint: MKMapPoint?
	
	func coordinate() -> CLLocationCoordinate2D {
		return CLLocationCoordinate2DMake(self.latitude, self.longitude)
	}
	
	func mapPoint() -> MKMapPoint {
		if self.tempMapPoint == nil {
			self.tempMapPoint = MKMapPointForCoordinate(self.coordinate())
		}
		
		return self.tempMapPoint!
	}
}
