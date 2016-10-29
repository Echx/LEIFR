//
//  LFZoomLevel.swift
//  LEIFR
//
//  Created by Lei Mingyu on 30/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

class LFZoomLevel: NSObject {
    var zoomLevel: Int
    var zoomScale: MKZoomScale
    
    init(zoomLevel: Int) {
        self.zoomLevel = zoomLevel
        self.zoomScale = MKZoomScale(pow(2.0, Double(zoomLevel)) / (MKMapSizeWorld.width / 256.0))
    }
    
    init(zoomScale: MKZoomScale) {
        self.zoomScale = zoomScale
        self.zoomLevel = max(0, Int(log2(MKMapSizeWorld.width / 256.0) + log2(Double(zoomScale))))
    }
}
