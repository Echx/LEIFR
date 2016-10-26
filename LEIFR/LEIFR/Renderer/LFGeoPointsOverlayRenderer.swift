//
//  LFGeoPointsOverlayRenderer.swift
//  LEIFR
//
//  Created by Jinghan Wang on 26/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFGeoPointsOverlayRenderer: MKOverlayRenderer {
	
	var filledPercentage: CGFloat = 0.9
	
	fileprivate var cache = [String: [CGPoint]]()
	fileprivate var cacheAccessQueue = DispatchQueue(label: "CACHE_QUEUE")
	
	
	override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		return true
		let key = self.cacheKey(for: mapRect, zoomScale: zoomScale)
		if let _ = cache[key] {
			return true
		} else {
			let region = MKCoordinateRegionForMapRect(mapRect)
			let gridSize = self.gridSize(for: zoomScale)
			LFDatabaseManager.sharedManager().getPointsInRegion(region, gridSize: gridSize, completion: {
				coordinates in
				let points = coordinates.map({ return self.point(for: MKMapPointForCoordinate($0)) })
				self.cacheAccessQueue.async {
					self.cache[key] = points
					self.setNeedsDisplayIn(mapRect, zoomScale: zoomScale)
				}
			})
			
			return false
		}
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
		let key = self.cacheKey(for: mapRect, zoomScale: zoomScale)
		let manager = LFDatabaseManager.sharedManager()
		let region = MKCoordinateRegionForMapRect(mapRect)
		var coordinates = [CLLocationCoordinate2D]()
		let gridSize = self.gridSize(for: zoomScale)
		
		manager.asyncDatabaseQueue.sync {
			manager.databaseQueue.inDatabase({
				database in
				let xMin = region.center.longitude - region.span.longitudeDelta
				let yMin = region.center.latitude - region.span.latitudeDelta
				let xMax = region.center.longitude + region.span.longitudeDelta
				let yMax = region.center.latitude + region.span.latitudeDelta
				
				let screenPolygon = "GeomFromText('POLYGON((\(xMin) \(yMin), \(xMin) \(yMax), \(xMax) \(yMax), \(xMax) \(yMin)))')"
				let select = "SELECT track_id, AsGeoJSON(DissolvePoints(SnapToGrid(GUnion(Intersection(SnapToGrid(track_geometry, 0.0, 0.0, \(gridSize), \(gridSize)), " + screenPolygon + ")), \(gridSize)))) FROM tracks "
				let querySQL = select + "WHERE MbrOverlaps(track_geometry, " + screenPolygon + ") OR MbrContains(track_geometry, " + screenPolygon + ")"
				
				var array = [String]()
				
				if let results = manager.database.executeQuery(querySQL, withArgumentsIn: nil) {
					while (results.next()) {
						if results.hasAnotherRow() {
							if let geoJSON = results.string(forColumnIndex: 1) {
								array.append(geoJSON)
							}
						}
					}
				}
				
				coordinates = LFGeoJSONManager.convertToCoordinates(geoJSON: array)
			})
		}
		
		var cachedPoints: [CGPoint]?

//		cacheAccessQueue.sync {
//			cachedPoints = self.cache[key]
//		}
		
		cachedPoints = coordinates.map({ return self.point(for: MKMapPointForCoordinate($0)) })
		
		if let points = cachedPoints {
			let gridSize = self.gridSizeDrawn(for: zoomScale)
			context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.1)
			for point in points {
				let rect = CGRect(x: point.x - gridSize/2, y: point.y - gridSize/2, width: gridSize, height: gridSize)
				context.fill(rect)
			}
			self.cacheAccessQueue.async {
				self.cache.removeValue(forKey: key)
			}
		}
	}
	
	fileprivate func cacheKey(for mapRect: MKMapRect, zoomScale: MKZoomScale) -> String {
		return "\(mapRect), \(zoomScale)"
	}
	
	fileprivate func gridSize(for zoomScale: MKZoomScale) -> Double {
		return 1 / Double(zoomScale) / 20000
	}
	
	fileprivate func gridSizeDrawn(for zoomScale: MKZoomScale) -> CGFloat {
		return 1 / zoomScale * 30
	}
	
}


class LFGeoPointsOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
}
