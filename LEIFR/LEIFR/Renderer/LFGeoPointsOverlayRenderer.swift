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
		var cachedPoints: [CGPoint]?
		
		cacheAccessQueue.sync {
			cachedPoints = self.cache[key]
		}
		
		if let points = cachedPoints {
			let gridSize = self.gridSizeDrawn(for: zoomScale)
			context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.1)
			for point in points {
				let rect = CGRect(x: point.x - gridSize/2, y: point.y - gridSize/2, width: gridSize, height: gridSize)
				context.fill(rect)
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
