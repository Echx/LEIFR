//
//  LFDatabaseManager.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit
import wkb_ios

class LFDatabaseManager: NSObject {
	static let shared = LFDatabaseManager()
	fileprivate var databaseQueue: FMDatabaseQueue!
	var database: FMDatabase!
	
	func databasePathWithName(_ name: String) -> String {
		let databaseDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
		let destinationPath = databaseDirectory + "/\(name).sqlite"
		return destinationPath
	}
	
	func createDatabase(_ name: String) -> Bool {
		let destinationPath = self.databasePathWithName(name)
		let fileManager = FileManager.default
		
		if !fileManager.fileExists(atPath: destinationPath) {
			if let sourcePath = Bundle.main.path(forResource: "default", ofType: "sqlite") {
				do {
					try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
				} catch {
					return false
				}
			} else {
				print("Database template not exist")
			}
		} else {
			print("Database already existed with name: \(name)")
		}
		
		self.database = FMDatabase(path: destinationPath)
		self.databaseQueue = FMDatabaseQueue(path: destinationPath)
		
		return true
	}
	
	func removeDatabase(_ name: String) -> Bool {
		let destinationPath = self.databasePathWithName(name)
		let fileManager = FileManager.default
		
		if fileManager.fileExists(atPath: destinationPath) {
			do {
				try fileManager.removeItem(atPath: destinationPath)
			} catch {
				return false
			}
		}
		
		return true
	}
	
	func openDatabase() -> Bool {
		if self.database == nil {
			if !self.createDatabase("default") {
				print("Failed to create database.")
				return false
			}
		}
		
		if self.database.open() {
			print("Database opened:  \(self.database.databasePath())")
			return true
		} else {
			print("Database failed to open")
			return false
		}
	}
	
	func closeDatabase() -> Bool {
		return self.database.close()
	}
	
	func savePath(_ path: LFPath, completion:@escaping ((Bool) -> Void)) {
		self.databaseQueue.inDatabase({
			database in
			let insertSQL = "INSERT OR REPLACE INTO tracks (track_geometry) VALUES (LineStringFromText('\(path.WKTString())'));"
			let isSuccessful = self.database.executeStatements(insertSQL)
			completion(isSuccessful)
		})
	}
    
    func getPointsInRegion(_ region: MKCoordinateRegion, completion:@escaping (([CLLocationCoordinate2D]) -> Void)) {
        self.getPointsInRegion(region, gridSize: 0.0, completion: completion)
    }
    
    func getPointsInRegion(_ region: MKCoordinateRegion, gridSize: Double, completion:@escaping (([CLLocationCoordinate2D]) -> Void)) {
        self.getPointsGeoJSONInRegion(region, gridSize: gridSize) {
            geoJSON in
            
            let coordinates = LFGeoJSONManager.convertToCoordinates(geoJSON: geoJSON)
            completion(coordinates)
        }
    }
	
    func getPointsGeoJSONInRegion(_ region: MKCoordinateRegion, completion:@escaping (([String]) -> Void)) {
        self.getPointsGeoJSONInRegion(region, gridSize: 0.0, completion: completion)
    }
    
    func getPointsGeoJSONInRegion(_ region: MKCoordinateRegion, gridSize: Double, completion:@escaping (([String]) -> Void)) {
		self.databaseQueue.inDatabase({
			database in
			let xMin = region.center.longitude - region.span.longitudeDelta
			let yMin = region.center.latitude - region.span.latitudeDelta
			let xMax = region.center.longitude + region.span.longitudeDelta
			let yMax = region.center.latitude + region.span.latitudeDelta
			
			let screenPolygon = "GeomFromText('POLYGON((\(xMin) \(yMin), \(xMin) \(yMax), \(xMax) \(yMax), \(xMax) \(yMin)))')"
			let select = "SELECT track_id, AsGeoJSON(DissolvePoints(SnapToGrid(GUnion(Intersection(SnapToGrid(track_geometry, 0.0, 0.0, \(gridSize), \(gridSize)), " + screenPolygon + ")), \(gridSize)))) FROM tracks "
			let querySQL = select + "WHERE MbrOverlaps(track_geometry, " + screenPolygon + ") OR MbrContains(track_geometry, " + screenPolygon + ")"
			
			var array = [String]()
			
			if let results = self.database.executeQuery(querySQL, withArgumentsIn: nil) {
				while (results.next()) {
					if results.hasAnotherRow() {
						if let geoJSON = results.string(forColumnIndex: 1) {
							array.append(geoJSON)
						}
					}
				}
			}
			
			DispatchQueue.main.async {
				completion(array)
			}
		})
    }

	
	func getPathsInRegion(_ region: MKCoordinateRegion, completion: @escaping (([LFPath]) -> Void)) {
		databaseQueue.inDatabase({
			database in
			let xMin = region.center.longitude - region.span.longitudeDelta
			let yMin = region.center.latitude - region.span.latitudeDelta
			let xMax = region.center.longitude + region.span.longitudeDelta
			let yMax = region.center.latitude + region.span.latitudeDelta
			
			let tolerance = region.span.longitudeDelta / 100
			
			let screenPolygon = "GeomFromText('POLYGON((\(xMin) \(yMin), \(xMin) \(yMax), \(xMax) \(yMax), \(xMax) \(yMin)))')"
			let select = "SELECT track_id, AsBinary(Intersection(Simplify(track_geometry, \(tolerance)), " + screenPolygon + ")) FROM tracks "
			let querySQL = select + "WHERE MbrOverlaps(track_geometry, " + screenPolygon + ") OR MbrContains(track_geometry, " + screenPolygon + ")"
			
			let results = self.database.executeQuery(querySQL, withArgumentsIn: nil)!
			
			var paths = [LFPath]()
			
			while (results.next()) {
				if results.hasAnotherRow() {
					if let data = results.data(forColumnIndex: 1) {
						let reader = WKBByteReader(data: data)
						reader?.byteOrder = Int(CFByteOrderBigEndian.rawValue)
						let geometry = WKBGeometryReader.readGeometry(with: reader)
						
						if let lineString = geometry as? WKBLineString {
							let path = LFPath(lineString: lineString)
							paths.append(path)
						} else if let multiLineString = geometry as? WKBMultiLineString {
							print("multiline")
							for lineString in multiLineString.getLineStrings() {
								let path = LFPath(lineString: lineString as! WKBLineString)
								paths.append(path)
							}
						}
					}
				}
			}
			
			completion(paths)
		})
	}
	
    func getSnappedPathsInRegion(_ region: MKCoordinateRegion, completion: @escaping (([LFPath]) -> Void)) {
        self.getSnappedPathsInRegion(region, gridSize: 0.0, completion: completion)
    }
    
    func getSnappedPathsInRegion(_ region: MKCoordinateRegion, gridSize: Double, completion: @escaping (([LFPath]) -> Void)) {
        databaseQueue.inDatabase({
            database in
            let xMin = region.center.longitude - region.span.longitudeDelta
            let yMin = region.center.latitude - region.span.latitudeDelta
            let xMax = region.center.longitude + region.span.longitudeDelta
            let yMax = region.center.latitude + region.span.latitudeDelta
            
            let screenPolygon = "GeomFromText('POLYGON((\(xMin) \(yMin), \(xMin) \(yMax), \(xMax) \(yMax), \(xMax) \(yMin)))')"
            let select = "SELECT track_id, AsBinary(SnapToGrid(GUnion(Intersection(SnapToGrid(track_geometry, 0.0, 0.0, \(gridSize), \(gridSize)), " + screenPolygon + ")), \(gridSize))) FROM tracks "
            let querySQL = select + "WHERE MbrOverlaps(track_geometry, " + screenPolygon + ") OR MbrContains(track_geometry, " + screenPolygon + ")"
            
            let results = self.database.executeQuery(querySQL, withArgumentsIn: nil)!
            
            var paths = [LFPath]()
            
            while (results.next()) {
                if results.hasAnotherRow() {
                    if let data = results.data(forColumnIndex: 1) {
                        let reader = WKBByteReader(data: data)
                        reader?.byteOrder = Int(CFByteOrderBigEndian.rawValue)
                        let geometry = WKBGeometryReader.readGeometry(with: reader)
                        
                        if let lineString = geometry as? WKBLineString {
                            let path = LFPath(lineString: lineString)
                            paths.append(path)
                        } else if let multiLineString = geometry as? WKBMultiLineString {
                            print("multiline")
                            for lineString in multiLineString.getLineStrings() {
                                let path = LFPath(lineString: lineString as! WKBLineString)
                                paths.append(path)
                            }
                        }
                    }
                }
            }
            
            completion(paths)
        })
    }
}
