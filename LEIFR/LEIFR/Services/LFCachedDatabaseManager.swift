//
//  LFCachedDatabaseManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 29/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import RealmSwift
import MapKit

class LFCachedDatabaseManager: NSObject {
    fileprivate static let manager = LFCachedDatabaseManager()
    
    fileprivate let cacheRealm = try! Realm()
    
    class func sharedManager() -> LFCachedDatabaseManager {
        return self.manager
    }
    
    func savePoints(coordinates: [CLLocationCoordinate2D], zoomLevel: Int) -> Bool {
        return false
    }
    
    func savePoint(coordinate: CLLocationCoordinate2D, zoomLevel: Int) -> Bool {
        let mapPoint = MKMapPointForCoordinate(coordinate)
        let newPoint = LFCachedPoint()
        newPoint.x = mapPoint.x
        newPoint.y = mapPoint.y
        newPoint.count = 1
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter("level == \(zoomLevel)")
        var currentLevel = LFCachedLevel()
        
        if currentLevels.count > 0 {
            currentLevel = currentLevels[0]
        }
        
        try! cacheRealm.write {
            cacheRealm.add(newPoint)
            currentLevel.points.append(newPoint)
        }
        
        return false
    }
    
    func getPointsInRegion(_ region: MKCoordinateRegion) -> [MKMapPoint] {
        let result = [MKMapPoint]()
        
        return result
    }
}
