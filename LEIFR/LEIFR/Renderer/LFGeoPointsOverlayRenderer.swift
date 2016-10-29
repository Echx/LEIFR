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
		let region = MKCoordinateRegionForMapRect(mapRect)
		let mapPoints = LFCachedDatabaseManager.shared.getPointsInRegion(region, zoomScale: zoomScale)
		let gridSize = self.gridSizeDrawn(for: zoomScale)
		context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.1)
		for mapPoint in mapPoints {
			let point = self.point(for: mapPoint)
			let rect = CGRect(x: point.x - gridSize/2, y: point.y - gridSize/2, width: gridSize, height: gridSize)
			context.fill(rect)
		}
	}
	
	fileprivate func cacheKey(for mapRect: MKMapRect, zoomScale: MKZoomScale) -> String {
		return "\(mapRect), \(zoomScale)"
	}
	
	fileprivate func gridSizeDrawn(for zoomScale: MKZoomScale) -> CGFloat {
		return 1 / zoomScale * 30
	}
}


class LFGeoPointsOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
}
