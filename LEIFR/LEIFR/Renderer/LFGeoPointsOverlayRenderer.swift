//
//  LFGeoPointsOverlayRenderer.swift
//  LEIFR
//
//  Created by Jinghan Wang on 26/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import RealmSwift

class LFGeoPointsOverlayRenderer: MKOverlayRenderer {
	
	fileprivate var cacheAccessQueue = DispatchQueue(label: "CACHE_QUEUE")
	
	
	override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		return true
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let dbManager = LFCachedDatabaseManager.shared
		let cachedPoints = dbManager.getPointsInRect(mapRect, zoomScale: zoomScale)
		guard cachedPoints.count > 0 else {
			return
		}
		
		let gridSize = self.gridSizeDrawn(for: zoomScale)
		// quick and dirty fix
		let maxCount = dbManager.getMaxPointsCountIn(zoomScale: zoomScale) + 1
		let minCount = dbManager.getMinPointsCountIn(zoomScale: zoomScale) + 1
		let maxAlpha = 1.0
		let minAlpha = 0.1
		
		
		for cachedPoint in cachedPoints {
			let mapPoint = MKMapPoint(x: Double(cachedPoint.x), y: Double(cachedPoint.y))
			let point = self.point(for: mapPoint)
			let rect = CGRect(x: point.x, y: point.y, width: gridSize, height: gridSize)
			let count = cachedPoint.count
			let weightedAlpha = Double(count - minCount) / Double(maxCount - minCount) * (maxAlpha - minAlpha) + minAlpha
			context.setFillColor(red: 0, green: 0, blue: 0, alpha: CGFloat(weightedAlpha))
			context.fill(rect)
		}
	}
	
	fileprivate func gridSizeDrawn(for zoomScale: MKZoomScale) -> CGFloat {
		return 1 / zoomScale * 15
	}
}


class LFGeoPointsOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
}
