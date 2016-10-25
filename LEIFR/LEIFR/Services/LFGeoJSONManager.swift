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
        let wrappedResult = "{\"type\": \"Feature\", \"properties\": {}, \"geometry\":" + geometry + "}";
        let data = wrappedResult.data(using: .utf8)!
        if (try? JSONSerialization.jsonObject(with: data)) != nil {
            return wrappedResult
        } else {
            print("invalid JSON!")
            return nil
        }
    }
	
	class func wrapArray(geometryArray: [String]) -> String? {
		var result = "{\"type\": \"FeatureCollection\", \"features\": ["
		for (index, element) in geometryArray.enumerated() {
			if let geoJSON = self.wrap(geometry: element) {
				if (index != 0) {
					result.append(",")
				}
				result.append(geoJSON)
			}
		}
		result.append("]}")
		return result
	}
}
