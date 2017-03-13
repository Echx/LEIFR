//
//  LFCurrentPathOverlayRenderer.swift
//  LEIFR
//
//  Created by Jinghan Wang on 13/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFCurrentPathOverlayRenderer: MKOverlayRenderer {

	override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
		return true
	}
	
	override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
		if let overlay = self.overlay as? LFCurrentPathOverlay {
			let currentTime = NSDate()
			let gridSize = self.gridSizeDrawn(for: zoomScale)
			for (coordinate, time) in overlay.coordinates {
				let timeInterval = currentTime.timeIntervalSince(time)
				let alpha = 1 - min(timeInterval / overlay.fadeTime, 1)
				
				let mapPoint = MKMapPointForCoordinate(coordinate)
				let point = self.point(for: mapPoint)
				let rect = CGRect(x: point.x, y: point.y, width: gridSize, height: gridSize)
				
				context.setFillColor(red: 0, green: 0, blue: 0, alpha: CGFloat(alpha))
				context.fillEllipse(in: rect)
			}
		}
	}
	
	fileprivate func gridSizeDrawn(for zoomScale: MKZoomScale) -> CGFloat {
		return 1 / zoomScale * 10
	}
	
}

class LFCurrentPathOverlay: NSObject, MKOverlay {
	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var boundingMapRect: MKMapRect = MKMapRectWorld
	var coordinates = [(CLLocationCoordinate2D, Date)]()
	var fadeTime: TimeInterval = 120
	
	func addCoordinate(coordinate: CLLocationCoordinate2D) {
		if let first = coordinates.first {
			if Date().timeIntervalSince(first.1) > fadeTime {
				coordinates.removeFirst()
			}
		}
		
		coordinates.append((coordinate, Date()))
	}
}
