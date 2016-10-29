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
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter("level = \(zoomLevel)")
        var currentLevel = LFCachedLevel()
        
        if currentLevels.count > 0 {
            currentLevel = currentLevels.first!
        } else {
            try! cacheRealm.write {
                currentLevel.level = zoomLevel
                cacheRealm.add(currentLevel)
            }
        }
        
        
        let x = Int(mapPoint.x)
        let y = Int(mapPoint.y)
        
        let cachedPoints = currentLevel.points.filter("x = \(x) AND y = \(y)")
        if cachedPoints.count > 0 {
            let cachedPoint = cachedPoints.first!
            try! cacheRealm.write {
                cachedPoint.count += 1
            }
        } else {
            let newPoint = LFCachedPoint()
            newPoint.count = 1
            newPoint.x = x
            newPoint.y = y
            
            try! cacheRealm.write {
                cacheRealm.add(newPoint)
                currentLevel.points.append(newPoint)
            }
        }
    }
    
    func getPointsInRegion(_ region: MKCoordinateRegion, zoomScale: MKZoomScale) -> [MKMapPoint] {
        let zoomLevel = self.zoomLevel(for: zoomScale)
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter("level = \(zoomLevel)")
        let result = [MKMapPoint]()
        guard currentLevels.count > 0 else {
            let gridSize = self.gridSize(for: zoomScale)
            
            LFDatabaseManager.sharedManager().getPointsInRegion(region, gridSize: gridSize, completion: {
                coordinates in
                
                self.savePoints(coordinates: coordinates, zoomLevel: zoomLevel)
            })
            
            return result
        }
        
        return currentLevels[0].points.map{MKMapPoint(x: Double($0.x), y: Double($0.y))}
    }
    
    fileprivate func gridSize(for zoomScale: MKZoomScale) -> Double {
        return 1 / Double(zoomScale) / 20000
    }
    
    fileprivate func zoomLevel(for zoomScale: MKZoomScale) -> Int {
        return max(0, Int(log2(MKMapSizeWorld.width / 256.0) + log2(Double(zoomScale))))
    }
}
