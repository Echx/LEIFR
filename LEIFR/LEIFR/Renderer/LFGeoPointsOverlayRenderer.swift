//
//  LFGeoPointsOverlayRenderer.swift
//  LEIFR
//
//  Created by Jinghan Wang on 26/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFGeoPointsOverlayRenderer: MKOverlayRenderer {
	
	var gridSize: CGFloat = 10000
	var filledPercentage: CGFloat = 0.9
	
	override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		return true
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let databaseManager = LFDatabaseManager.sharedManager()
		
		gridSize = 1 / zoomScale * 25
		
		let cgRect = rect(for: mapRect)
		context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0.2)
		
		let xNumberOfGrid = Int(ceil(cgRect.width / gridSize)) * 2
		let yNumberOfGrid = Int(ceil(cgRect.width) / gridSize) * 2
		let minX = CGFloat(Int(cgRect.minX) / Int(gridSize) * Int(gridSize))
		let minY = CGFloat(Int(cgRect.minY) / Int(gridSize) * Int(gridSize))
		
		for i in 0..<xNumberOfGrid {
			for j in 0..<yNumberOfGrid {
				let x = CGFloat(i) * gridSize + minX
				let y = CGFloat(j) * gridSize + minY
				let size = gridSize * filledPercentage
				let rect = CGRect(x: x, y: y, width: size, height: size)
				context.fill(rect)
			}
		}
        
        databaseManager.getPointsInRegion(MKCoordinateRegionForMapRect(mapRect)) {
            coordinates in
            
            // has some bug here, only enter once
            let region = MKCoordinateRegionForMapRect(mapRect)
            let minLong = region.center.longitude - region.span.longitudeDelta / 2
            let maxLong = region.center.longitude + region.span.longitudeDelta / 2
            let minLat = region.center.latitude - region.span.latitudeDelta / 2
            let maxLat = region.center.latitude + region.span.latitudeDelta / 2

            print(region.span.latitudeDelta)
            for coordinate in coordinates {
                let i = Int((coordinate.longitude - minLong) / region.span.longitudeDelta) * xNumberOfGrid
                let j = Int((coordinate.latitude - minLat) / region.span.latitudeDelta) * yNumberOfGrid
                
                print("\(i), \(j)")
            }
        }
	}
	
}


class LFGeoPointsOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
}
