//
//  LFCachedDatabaseManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 29/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import RealmSwift
import MapKit
import Mapbox

class LFCachedDatabaseManager: NSObject {
    static let shared = LFCachedDatabaseManager()
    
    fileprivate let cacheRealm = try! Realm()
    fileprivate let bufferSize = 200
    fileprivate let maxLevel = 15
	fileprivate let reverseGeocodingSamplingLevel = 13
    
    func savePoints(coordinates: [CLLocationCoordinate2D], zoomLevel: Int) {
        let cacheRealm = try! Realm()
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter("level = \(zoomLevel)")
        var currentLevel = LFCachedLevel()
        
        if currentLevels.count > 0 {
            currentLevel = currentLevels.first!
        } else {
            try! cacheRealm.write {
                currentLevel.level = zoomLevel
                cacheRealm.add(currentLevel)
            }
        }
        
        var size = coordinates.count
        var current = 0
        while size > 0 {
            var count = 0
            size -= bufferSize
            cacheRealm.beginWrite()
            while current < coordinates.count - 1 && count < bufferSize - 1 {
                current += 1
                count += 1
				
				if zoomLevel == reverseGeocodingSamplingLevel {
					LFReverseGeocodingManager.shared.reverseGeocoding(coordinate: coordinates[current])
				}
				
                let mapPoint = MKMapPointForCoordinate(coordinates[current])
                let x = Int(mapPoint.x)
                let y = Int(mapPoint.y)
                
                let cachedPoints = currentLevel.points.filter("x = \(x) AND y = \(y)")
                if cachedPoints.count > 0 {
                    let cachedPoint = cachedPoints.first!
                    cachedPoint.count += 1
                } else {
                    let newPoint = LFCachedPoint()
                    newPoint.count = 1
                    newPoint.x = x
                    newPoint.y = y
                    currentLevel.points.append(newPoint)
                }
            }
            try! cacheRealm.commitWrite()
        }
    }
    
    func getPointsIn(zoomLevel: Int) -> [LFCachedPoint] {
        let cacheRealm = try! Realm()
        let levelPredicate = "level = \(zoomLevel)"
        
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter(levelPredicate)
        
        guard currentLevels.count > 0 else {
            return [LFCachedPoint]()
        }
        
        let points = currentLevels[0].points
        return Array(points)
    }
    
    func getPointsIn(_ rect: MKMapRect, zoomScale: MKZoomScale) -> [LFCachedPoint] {
        let zoomLevel = zoomScale.toZoomLevel()
        let minX = Int(rect.origin.x - rect.size.width)
        let maxX = Int(rect.origin.x + rect.size.width)
        let minY = Int(rect.origin.y - rect.size.height)
        let maxY = Int(rect.origin.y + rect.size.height)
        
        return getPointsWith(minX: minX, maxX: maxX, minY: minY, maxY: maxY, zoomLevel: zoomLevel)
    }
    
    func getPointsIn(_ bounds: MGLCoordinateBounds, zoomLevel: Int) -> [LFCachedPoint] {
        let swPoint = MKMapPointForCoordinate(bounds.sw)
        let nePoint = MKMapPointForCoordinate(bounds.ne)
        let minX = Int(swPoint.x)
        let maxX = Int(nePoint.x)
        let minY = Int(nePoint.y)
        let maxY = Int(swPoint.y)
        
        return getPointsWith(minX: minX, maxX: maxX, minY: minY, maxY: maxY, zoomLevel: zoomLevel)
    }
    
    func getPointsWith(minX: Int, maxX: Int, minY: Int, maxY: Int, zoomLevel: Int) -> [LFCachedPoint] {
        let cacheRealm = try! Realm()
        let levelPredicate = "level = \(zoomLevel)"
        let xPredicate = "x >= \(minX) AND x <= \(maxX)"
        let yPredicate = "y >= \(minY) AND y <= \(maxY)"
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter(levelPredicate)
        
        guard currentLevels.count > 0 else {
            return [LFCachedPoint]()
        }
        
        let points = currentLevels[0].points.filter("\(xPredicate) AND \(yPredicate)")
        return Array(points)
    }

    
    func getMaxPointsCountIn(zoomScale: MKZoomScale) -> Int {
        let zoomLevel = zoomScale.toZoomLevel()
        let cacheRealm = try! Realm()
        let levelPredicate = "level = \(zoomLevel)"
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter(levelPredicate)
        
        guard currentLevels.count > 0 else {
            return 0
        }
        
        let points = currentLevels[0].points
        let count = points.max(ofProperty: "count") as Int?
        return count!
    }
    
    func getMinPointsCountIn(zoomScale: MKZoomScale) -> Int {
        let zoomLevel = zoomScale.toZoomLevel()
        let cacheRealm = try! Realm()
        let levelPredicate = "level = \(zoomLevel)"
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter(levelPredicate)
        
        guard currentLevels.count > 0 else {
            return 0
        }
        
        let points = currentLevels[0].points
        let count = points.min(ofProperty: "count") as Int?
        return count!
    }
    
    func getPointsCountIn(zoomScale: MKZoomScale) -> Int {
        let zoomLevel = zoomScale.toZoomLevel()
        let cacheRealm = try! Realm()
        let levelPredicate = "level = \(zoomLevel)"
        
        return cacheRealm.objects(LFCachedLevel.self).filter(levelPredicate).count
    }
    
    func synchronizeDatabase() {
        print("synchronizing database")
    }
    
    func reconstructDatabase() {
        clearDatabase()
		resetCountries()
		
        let maxX: CLLocationDegrees = 180.0
        let maxY: CLLocationDegrees = 90.0
        let minX: CLLocationDegrees = -180.0
        let minY: CLLocationDegrees = -90.0
        
		let notificationCenter = NotificationCenter.default
		
        let min = 1
        // cached for 1-15(incl.)
        
        for level in min...maxLevel {
			
            let gridSize = self.gridSize(for: level)
            let step: Double = pow(2.0, Double(level / 3))
            let stepX = (maxX - minX) / step
            let stepY = (maxY - minY) / step
            var x = minX
            
            var count = 0
            while x < maxX {
                var y = minY
                while y < maxY {
                    count += 1
                    let bounds = MGLCoordinateBounds(sw: CLLocationCoordinate2DMake(y, x), ne: CLLocationCoordinate2DMake(y + stepY, x + stepX))
                    LFDatabaseManager.shared.getPointsInBounds(bounds, gridSize: gridSize, completion: {
                        coordinates in
                        
//                        print(bounds)
//                        print(level)
                        print(coordinates.count)
                        print("\(count)/\(step * step)")
                        self.savePoints(coordinates: coordinates, zoomLevel: level)
                        notificationCenter.post(name: NSNotification.Name(rawValue: LFNotification.databaseReconstructionProgress), object: nil, userInfo: ["progress": self.progress(for: level, count: count)])
                    })
                    y += stepY
                }
                x += stepX
            }
        }
		
		notificationCenter.post(name: NSNotification.Name(rawValue: LFNotification.databaseReconstructionComplete), object: nil, userInfo: nil)
    }
    
    func reconstructDatabaseFor(rect: MKMapRect, zoomScale: MKZoomScale) {
        let dbManager = LFDatabaseManager.shared
        let zoomLevel = zoomScale.toZoomLevel()
        let gridSize = self.gridSize(for: zoomLevel)
        dbManager.getPointsInRegion(MKCoordinateRegionForMapRect(rect), gridSize: gridSize) {
            coordinates in
            
            print(coordinates.count)
            self.savePoints(coordinates: coordinates, zoomLevel: zoomLevel)
        }
    }
    
    func reconstructDatabaseFor(bounds: MGLCoordinateBounds, zoomLevel: Int) {
        let dbManager = LFDatabaseManager.shared
        let gridSize = self.gridSize(for: zoomLevel)
        dbManager.getPointsInBounds(bounds, gridSize: gridSize) {
            coordinates in
            
            print(coordinates.count)
            self.savePoints(coordinates: coordinates, zoomLevel: zoomLevel)
        }
    }
	
	func cachePath(with trackId: Int) {
		for level in 1...maxLevel {
			print("processing path at level \(level)")
			
			let gridSize = self.gridSize(for: level)
			
			LFDatabaseManager.shared.getPointsWithTrackID(id: trackId, gridSize: gridSize, completion: {
				coordinates in
				self.savePoints(coordinates: coordinates, zoomLevel: level)
			})
		}
		
		print("path processing completed")
	}
	
    func clearDatabase() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func destroyDatabase() {
        let databaseDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let array = try! FileManager.default.contentsOfDirectory(atPath: databaseDirectory)
        
        for name in array {
            if name != "default.sqlite" {
                try! FileManager.default.removeItem(atPath: "\(databaseDirectory)/\(name)")
            }
        }
    }
    
    fileprivate func gridSize(for zoomLevel: Int) -> Double {
        return 1 / pow(2.0, Double(zoomLevel)) * MKMapSizeWorld.width / 10240000
    }
    
    fileprivate func progress(for level: Int) -> CGFloat {
        // geometric sequence sum
        return pow(4, CGFloat(level)) / pow(4, CGFloat(maxLevel)) * 100
    }
    
    fileprivate func progress(for level: Int, count: Int) -> CGFloat {
        // geometric sequence sum
        return (pow(4, CGFloat(level)) * (CGFloat(count) / pow(4, CGFloat(level / 3))) + pow(4, CGFloat(level - 1))) / pow(4, CGFloat(maxLevel)) * 100 / 1.25
    }
}

// MARK: Statistics Related

extension LFCachedDatabaseManager {
	
	func resetCountries() {
		let realm = try! Realm()
		try! realm.write {
			realm.delete(realm.objects(LFCachedCountry.self))
		}
		let countryCodes = CountryCode.allCountries()
		try! realm.write {
			for codePair in countryCodes {
				let country = LFCachedCountry()
				country.continentCode = codePair[0]
				country.code = codePair[1]
				realm.add(country)
			}
		}
	}
	
	func updateCountryVisited(code: String) {
		let realm = try! Realm()
		if realm.objects(LFCachedCountry.self).count == 0 {
			self.resetCountries()
		}
		
		if let first = realm.objects(LFCachedCountry.self).filter("code == '\(code)'").first {
			guard !first.isInvalidated else {
				return
			}
			
			guard !first.visited else {
				return
			}
			
			try! realm.write {
				first.visited = true
			}
		}
	}
	
	func getVisitedCountries() -> [LFCachedCountry] {
		let realm = try! Realm()
		if realm.objects(LFCachedCountry.self).count == 0 {
			self.resetCountries()
		}
		let countries = Array(realm.objects(LFCachedCountry.self).filter("visited == YES"))
		return countries
	}
	
	func getAllCountries() -> [LFCachedCountry] {
		let realm = try! Realm()
		if realm.objects(LFCachedCountry.self).count == 0 {
			self.resetCountries()
		}
		let sortDescriptors = [
			SortDescriptor(property: "visited", ascending: false),
			SortDescriptor(property: "continentCode", ascending: true),
			SortDescriptor(property: "code", ascending: true)
		]
		let countries = realm.objects(LFCachedCountry.self).sorted(by: sortDescriptors)
		return Array(countries)
	}
	
	func getCountriesFromContinent(continentCode: String)  -> [LFCachedCountry] {
		let realm = try! Realm()
		if realm.objects(LFCachedCountry.self).count == 0 {
			self.resetCountries()
		}
		let sortDescriptors = [
			SortDescriptor(property: "visited", ascending: false),
			SortDescriptor(property: "code", ascending: true)
		]
		let countries = realm.objects(LFCachedCountry.self).filter("continentCode == '\(continentCode.uppercased())'").sorted(by: sortDescriptors)
		return Array(countries)
	}
}
