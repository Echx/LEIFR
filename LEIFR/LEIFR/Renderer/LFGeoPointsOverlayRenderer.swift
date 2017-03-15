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
	fileprivate let minimumAlpha = 0.2
	fileprivate let maximumAlpha = 0.8
	fileprivate let overlayColor = UIColor.black
	fileprivate let countCapForAlphaChange = 10.0
	
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
		
		for cachedPoint in cachedPoints {
			let mapPoint = MKMapPoint(x: Double(cachedPoint.x), y: Double(cachedPoint.y))
			let point = self.point(for: mapPoint)
			let rect = CGRect(x: point.x, y: point.y, width: gridSize, height: gridSize)
			let count = cachedPoint.count
            
            let weightedAlpha = minimumAlpha + (maximumAlpha - minimumAlpha) * min(Double(count), countCapForAlphaChange) / countCapForAlphaChange
			context.setFillColor(overlayColor.withAlphaComponent(CGFloat(weightedAlpha)).cgColor)
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
