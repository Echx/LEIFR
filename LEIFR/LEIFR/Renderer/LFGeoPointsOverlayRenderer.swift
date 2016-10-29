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
	
	var filledPercentage: CGFloat = 0.9
	
	fileprivate var cache = [String: [CGPoint]]()
	fileprivate var cacheAccessQueue = DispatchQueue(label: "CACHE_QUEUE")
	
	
	override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        
        // testing block
//        let realm = try! Realm()
//        try! realm.write {
//            realm.deleteAll()
//        }
        // end of testing block

		let key = self.cacheKey(for: mapRect, zoomScale: zoomScale)
		if let _ = cache[key] {
			return true
		} else {
			let region = MKCoordinateRegionForMapRect(mapRect)
            
            DispatchQueue.main.async {
                let points = LFCachedDatabaseManager.sharedManager().getPointsInRegion(region, zoomScale: zoomScale)
                self.cacheAccessQueue.async {
                    self.cache[key] = points.map{self.point(for: $0)}
                    self.setNeedsDisplayIn(mapRect, zoomScale: zoomScale)
                }
            }
            
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
	
	fileprivate func gridSizeDrawn(for zoomScale: MKZoomScale) -> CGFloat {
		return 1 / zoomScale * 30
	}
	
}


class LFGeoPointsOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
}
