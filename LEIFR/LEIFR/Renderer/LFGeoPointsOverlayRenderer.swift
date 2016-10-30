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
		return zoomScale <= 1
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
		if zoomScale <= 1 {
			let mapPoints = LFCachedDatabaseManager.shared.getPointsInRect(mapRect, zoomScale: zoomScale * 2)
			let gridSize = self.gridSizeDrawn(for: zoomScale)
			context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.1)
			for mapPoint in mapPoints {
				let point = self.point(for: mapPoint)
				let rect = CGRect(x: point.x, y: point.y, width: gridSize, height: gridSize)
				context.fill(rect)
			}
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
