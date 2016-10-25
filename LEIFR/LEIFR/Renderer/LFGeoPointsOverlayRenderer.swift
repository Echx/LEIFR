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
	}
	
}


class LFGeoPointsOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
}
