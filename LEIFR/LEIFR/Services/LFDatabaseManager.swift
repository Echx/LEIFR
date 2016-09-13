//
//  LFDatabaseManager.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import MapKit

class LFDatabaseManager: NSObject {
	fileprivate static let manager = LFDatabaseManager()
	fileprivate var databaseQueue: FMDatabaseQueue!
	var database: FMDatabase!
	
	class func sharedManager() -> LFDatabaseManager {
		return self.manager
	}
	
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
		databaseQueue.inDatabase({
			database in
			let insertSQL = "INSERT OR REPLACE INTO tracks (track_geometry) VALUES (LineStringFromText('\(path.WKTString())'));"
			let isSuccessful = self.database.executeStatements(insertSQL)
			completion(isSuccessful)
		})
	}
	
	func getPathsInRegion(_ region: MKCoordinateRegion, completion: @escaping (([LFPath]) -> Void)){
		databaseQueue.inDatabase({
			database in
			let xMin = region.center.longitude - region.span.longitudeDelta
			let yMin = region.center.latitude - region.span.latitudeDelta
			let xMax = region.center.longitude + region.span.longitudeDelta
			let yMax = region.center.latitude + region.span.latitudeDelta
			
			let tolerance = region.span.longitudeDelta / 50
			
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
}
