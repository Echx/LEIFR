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
    
    func savePoints(coordinates: [CLLocationCoordinate2D], zoomLevel: Int) {
        for coordinate in coordinates {
            self.savePoint(coordinate: coordinate, zoomLevel: zoomLevel)
        }
    }
    
    func savePoint(coordinate: CLLocationCoordinate2D, zoomLevel: Int) {
        let mapPoint = MKMapPointForCoordinate(coordinate)
        let newPoint = LFCachedPoint()
        newPoint.x = mapPoint.x
        newPoint.y = mapPoint.y
        newPoint.count = 1
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter("level == \(zoomLevel)")
        var currentLevel = LFCachedLevel()
        
        if currentLevels.count > 0 {
            currentLevel = currentLevels[0]
        } else {
            try! cacheRealm.write {
                currentLevel.level = zoomLevel
                cacheRealm.add(currentLevel)
            }
        }
        
        try! cacheRealm.write {
            cacheRealm.add(newPoint)
            currentLevel.points.append(newPoint)
        }
    }
    
    func getPointsInRegion(_ region: MKCoordinateRegion, zoomScale: MKZoomScale) -> [MKMapPoint] {
        let zoomLevel = self.zoomLevel(for: zoomScale)
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter("level == \(zoomLevel)")
        let result = [MKMapPoint]()
        guard currentLevels.count > 0 else {
            let gridSize = self.gridSize(for: zoomScale)
            
            LFDatabaseManager.sharedManager().getPointsInRegion(region, gridSize: gridSize, completion: {
                coordinates in
                
                self.savePoints(coordinates: coordinates, zoomLevel: zoomLevel)
            })
            
            return result
        }
        
        return currentLevels[0].points.map{MKMapPoint(x: $0.x, y: $0.y)}
    }
    
    fileprivate func gridSize(for zoomScale: MKZoomScale) -> Double {
        return 1 / Double(zoomScale) / 20000
    }
    
    fileprivate func zoomLevel(for zoomScale: MKZoomScale) -> Int {
        return max(0, Int(log2(MKMapSizeWorld.width / 256.0) + log2(Double(zoomScale))))
    }
}
