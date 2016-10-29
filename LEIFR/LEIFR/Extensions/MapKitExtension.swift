//
//  MapKitExtension.swift
//  LEIFR
//
//  Created by Lei Mingyu on 30/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import MapKit

extension MKZoomScale {
    func toZoomLevel() -> Int {
        return Swift.max(0, Int(log2(MKMapSizeWorld.width / 256.0) + log2(Double(self))))
    }
}
