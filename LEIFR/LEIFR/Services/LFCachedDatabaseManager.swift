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
    static let shared = LFCachedDatabaseManager()
    
    fileprivate let cacheRealm = try! Realm()
    
    func savePoints(coordinates: [CLLocationCoordinate2D], zoomLevel: Int) {
        let cacheRealm = try! Realm()
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
        
        cacheRealm.beginWrite()
        
        for coordinate in coordinates {
            let mapPoint = MKMapPointForCoordinate(coordinate)
            
            let x = Int(mapPoint.x)
            let y = Int(mapPoint.y)
            
            let cachedPoints = currentLevel.points.filter("x = \(x) AND y = \(y)")
            if cachedPoints.count > 0 {
                let cachedPoint = cachedPoints.first!
                cachedPoint.count += 1
            } else {
                let newPoint = LFCachedPoint()
                newPoint.count = 1
                newPoint.x = x
                newPoint.y = y
                currentLevel.points.append(newPoint)
            }
        }
        
        try! cacheRealm.commitWrite()
    }
    
    func getPointsInRegion(_ region: MKCoordinateRegion, zoomScale: MKZoomScale) -> [MKMapPoint] {
        let zoomLevel = zoomScale.toZoomLevel()
		let cacheRealm = try! Realm()
        let currentLevels = cacheRealm.objects(LFCachedLevel.self).filter("level = \(zoomLevel)")
        
        guard currentLevels.count > 0 else {
            return [MKMapPoint]()
        }
        
        return currentLevels[0].points.map{MKMapPoint(x: Double($0.x), y: Double($0.y))}
    }
    
    func synchronizeDatabase() {
        print("synchronizing database")
    }
    
    func reconstructDatabase() {
        clearDatabase()
        
        for level in 1...21 {
            print("reconstructing database at level \(level)")
            
            let gridSize = self.gridSize(for: level)
            
            LFDatabaseManager.shared.getPointsInRegion(MKCoordinateRegionForMapRect(MKMapRectWorld), gridSize: gridSize, completion: {
                coordinates in
                
                self.savePoints(coordinates: coordinates, zoomLevel: level)
            })
        }
    }
    
    func clearDatabase() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func destroyDatabase() {
        let databaseDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let array = try! FileManager.default.contentsOfDirectory(atPath: databaseDirectory)
        
        for name in array {
            if name != "default.sqlite" {
                try! FileManager.default.removeItem(atPath: "\(databaseDirectory)/\(name)")
            }
        }
    }
    
    fileprivate func gridSize(for zoomLevel: Int) -> Double {
        return 1 / pow(2.0, Double(zoomLevel)) * MKMapSizeWorld.width / 5120000
    }
}
