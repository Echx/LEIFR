//
//  LFGeoJSONWrapper.swift
//  LEIFR
//
//  Wrapping a general geoJSON data into a MapBox-reginizable format
//
//  Created by Lei Mingyu on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFGeoJSONWrapper: NSObject {
    class func wrap(geometry: String) -> String? {
        let wrappedResult = "{\"type\": \"FeatureCollection\", \"features\": [{\"type\": \"Feature\", \"properties\": {}, \"geometry\":" + geometry + "}]}";
        let data = wrappedResult.data(using: .utf8)!
        if (try? JSONSerialization.jsonObject(with: data)) != nil {
            return wrappedResult
        } else {
            print("invalid JSON!")
            return nil
        }
    }
}
