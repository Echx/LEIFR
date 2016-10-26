//
//  LFGeoJSONManager.swift
//  LEIFR
//
//  Wrapping a general geoJSON data into a MapBox-reginizable format
//
//  Created by Lei Mingyu on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFGeoJSONManager: NSObject {
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
    
    class func convertToCoordinates(geoJSON: [String]) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = [];
        
        for pointsString in geoJSON {
            if let pointsData = pointsString.data(using: String.Encoding.utf8) {
                if let pointsObject = try? JSONSerialization.jsonObject(with: pointsData, options: []) as? [String: AnyObject] {
                    if let pointsArray = pointsObject!["coordinates"] as? [[Double]] {
                        for point in pointsArray {
                            coordinates.append(CLLocationCoordinate2DMake(point[1], point[0]))
                        }
                    }
                }
            }
        }
        
        return coordinates
    }
}
