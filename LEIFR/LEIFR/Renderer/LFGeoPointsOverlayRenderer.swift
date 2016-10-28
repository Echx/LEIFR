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
	
	fileprivate var cache = [String: [MKMapPoint]]()
	fileprivate var cacheAccessQueue = DispatchQueue(label: "CACHE_QUEUE")
	
	
	override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		return true
		
//		let key = self.cacheKey(for: mapRect, zoomScale: zoomScale)
//		if let _ = cache[key] {
//			print("true \(key)")
//			return true
//		} else {
//			print("false \(key)")
//			let region = MKCoordinateRegionForMapRect(mapRect)
//			let gridSize = self.gridSize(for: zoomScale)
//			LFDatabaseManager.sharedManager().getPointsInRegion(region, gridSize: gridSize, completion: {
//				coordinates in
//				let points = coordinates.map({ return self.point(for: MKMapPointForCoordinate($0)) })
//				self.cacheAccessQueue.async {
//					self.cache[key] = points
//					DispatchQueue.main.async {
//						self.setNeedsDisplayIn(mapRect, zoomScale: zoomScale)
//					}
//				}
//			})
//			
//			return true
//		}
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
		let key = self.cacheKey(for: mapRect, zoomScale: zoomScale)
		var cachedPoints: [MKMapPoint]?
		print("draw \(key)")
		cacheAccessQueue.sync {
			cachedPoints = self.cache[key]
		}
		
		if let points = cachedPoints {
			let gridSizeDrawn = self.gridSizeDrawn(for: zoomScale)
			context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.1)
			for mapPoint in points {
				let point = self.point(for: mapPoint)
				let rect = CGRect(x: point.x - gridSizeDrawn/2, y: point.y - gridSizeDrawn/2, width: gridSizeDrawn, height: gridSizeDrawn)
				
				context.fill(rect)
			}
		} else {
			let origin = mapRect.origin
			let width = Int(mapRect.size.width * 2)
			let newX = Int(origin.x) / width * width
			let newY = Int(origin.y) / width * width
			let newMapRect = MKMapRect(origin: MKMapPoint(x: Double(newX), y:Double(newY)), size: MKMapSize(width: Double(width), height: Double(width)))
			let newKey = self.cacheKey(for: newMapRect, zoomScale: zoomScale / 2)
			cacheAccessQueue.sync {
				cachedPoints = self.cache[newKey]
			}
			
			var mapPoints = [MKMapPoint]()

			if let points = cachedPoints {
				let gridSizeDrawn = self.gridSizeDrawn(for: zoomScale)
				context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.1)
				for mapPoint in points {
					let halfSize = Double(gridSizeDrawn * 1.242)
					do {
						mapPoints.append(mapPoint)
						let point = self.point(for: mapPoint)
						let rect = CGRect(x: point.x - gridSizeDrawn/2, y: point.y - gridSizeDrawn/2, width: gridSizeDrawn, height: gridSizeDrawn)
						context.fill(rect)
					}
					
					do {
						let fakeMapPoint = MKMapPointMake(mapPoint.x + halfSize, mapPoint.y)
						mapPoints.append(fakeMapPoint)
						let point = self.point(for: fakeMapPoint)
						let rect = CGRect(x: point.x - gridSizeDrawn/2, y: point.y - gridSizeDrawn/2, width: gridSizeDrawn, height: gridSizeDrawn)
						context.fill(rect)
					}
					
					do {
						let fakeMapPoint = MKMapPointMake(mapPoint.x, mapPoint.y + halfSize)
						mapPoints.append(fakeMapPoint)
						let point = self.point(for: fakeMapPoint)
						let rect = CGRect(x: point.x - gridSizeDrawn/2, y: point.y - gridSizeDrawn/2, width: gridSizeDrawn, height: gridSizeDrawn)
						context.fill(rect)
					}
					
					do {
						let fakeMapPoint = MKMapPointMake(mapPoint.x + halfSize, mapPoint.y + halfSize)
						mapPoints.append(fakeMapPoint)
						let point = self.point(for: fakeMapPoint)
						let rect = CGRect(x: point.x - gridSizeDrawn/2, y: point.y - gridSizeDrawn/2, width: gridSizeDrawn, height: gridSizeDrawn)
						context.fill(rect)
					}
				}
				
				self.cacheAccessQueue.sync {
					self.cache[key] = mapPoints
				}
			}
			
			DispatchQueue(label: key).async {
				let region = MKCoordinateRegionForMapRect(mapRect)
				let gridSize = self.gridSize(for: zoomScale)
				LFDatabaseManager.sharedManager().getPointsInRegion(region, gridSize: gridSize, completion: {
					coordinates in
					let mapPoints = coordinates.map({ return MKMapPointForCoordinate($0) })
					self.cacheAccessQueue.sync {
						self.cache[key] = mapPoints
					}
					
					DispatchQueue.main.async {
						self.setNeedsDisplayIn(mapRect, zoomScale: zoomScale)
					}
				})
			}
		}
	}
	
	fileprivate func cacheKey(for mapRect: MKMapRect, zoomScale: MKZoomScale) -> String {
		return "\(mapRect), \(zoomScale)"
	}
	
	fileprivate func gridSize(for zoomScale: MKZoomScale) -> Double {
		return 1 / Double(zoomScale) / 50000
	}
	
	fileprivate func gridSizeDrawn(for zoomScale: MKZoomScale) -> CGFloat {
		return CGFloat(self.gridSize(for: zoomScale)) * 600000
	}
	
}


class LFGeoPointsOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
}
