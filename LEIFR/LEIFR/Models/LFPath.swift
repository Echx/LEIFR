//
//  LFPath.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import wkb_ios

class LFPath: NSObject, NSSecureCoding {
	
	fileprivate let ArchiveKeyPropertyPoints = "ArchiveKeyPropertyPoints"
	
    fileprivate let minimumPointsPerPath = 5
	var points = [LFPoint]()
	var identifier: Int?
	var thumbnail: UIImage?
	
	var pointCount: Int { return self.points.count }
	var startTime: Date? { return points.first?.time }
	var endTime: Date? { return points.last?.time }
	private var country: String?
	var startingCountry: String {
		if let result = country {
			return result
		}
		
		country = "No Country"
		
		if let first = points.first {
			let countryCode = APReverseGeocoding.default().geocodeCountry(with: first.coordinate).code!
			let identifier = Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
			let name = NSLocale(localeIdentifier: identifier).displayName(forKey: NSLocale.Key.countryCode, value: countryCode)
			country = name
		}
		
		return country!
	}
	
	var interval: DateInterval? {
		guard points.count > 0 else {
			return nil
		}
		return DateInterval(start: startTime!, end: endTime!)
	}
	
	var boundedRegion: MKCoordinateRegion? {
		guard points.count > 0 else {
			return nil
		}
		
		var west = Double(CGFloat.greatestFiniteMagnitude)
		var east = Double(CGFloat.leastNormalMagnitude)
		var north = Double(CGFloat.greatestFiniteMagnitude)
		var south = Double(CGFloat.leastNormalMagnitude)

		for point in points {
			west = min(west, point.longitude)
			east = max(east, point.longitude)
			north = min(north, point.latitude)
			south = max(south, point.latitude)
		}
		
		let center = CLLocationCoordinate2D(latitude: (south + north) / 2.0, longitude: (east + west) / 2.0)
		if points.count == 1 {
			let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
			return MKCoordinateRegion(center: center, span: span)
		} else {
			let span = MKCoordinateSpan(latitudeDelta: (south - north) * 2.0, longitudeDelta: (east - west) * 2.0)
			return MKCoordinateRegion(center: center, span: span)
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
		if let last = points.last {
			if (last.latitude == latitude && last.longitude == longitude) {
				print("Duplicate Lat & Lon, point discarded")
				return
			}
		}
		
		print("Point saved")
		let point = LFPoint(longitude: longitude, latitude: latitude, altitude: altitude, time: time)
		LFReverseGeocodingManager.shared.reverseGeocoding(coordinate: point.coordinate)
		self.points.append(point)
	}
	
	func WKTString() -> String {
		let array = NSMutableArray()
		for point in points {
			array.add("\(point.x) \(point.y) \(point.z) \(point.m)")
		}
		
		let pointsString = array.componentsJoined(by: ", ")
		return "LINESTRINGZM(" + pointsString + ")"
	}
    
    func coordinates() -> [CLLocationCoordinate2D] {
        return self.points.map({
            (point) -> CLLocationCoordinate2D in
            
            return point.coordinate
        })
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
	
	func delete(completion:@escaping ((Error?) -> Void)) {
		guard let identifier = self.identifier else {
			return
		}
		
		LFDatabaseManager.shared.deletePath(identifier, completion: completion)
	}
	
	override var description: String {
		return self.WKTString()
	}
	
	// MARK: NSSecureCoding
	
	public required init?(coder aDecoder: NSCoder) {
		guard let points = aDecoder.decodeObject(forKey: ArchiveKeyPropertyPoints) as? [LFPoint] else {
			return nil
		}
		
		self.points = points
	}
	
	public func encode(with aCoder: NSCoder) {
		aCoder.encode(self.points, forKey: ArchiveKeyPropertyPoints)
	}
	
	public static var supportsSecureCoding: Bool {
		return true;
	}
}
