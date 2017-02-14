//
//  WKBExtension.swift
//  LEIFR
//
//  Created by Lei Mingyu on 15/2/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import wkb_ios

extension WKBPoint {
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
