//
//  LFGeoRecordManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFGeoRecordManager: NSObject {
    private static let manager = LFGeoRecordManager()
    private var bufferPath = LFPath()
    private var mutex = pthread_mutex_t()
    
    class func sharedManager() -> LFGeoRecordManager {
        return self.manager
    }
    
    func recordPoint(newPoint: CLLocation) {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        
        let coordinate = newPoint.coordinate
        self.bufferPath.addPoint(latitude: coordinate.latitude, longitude: coordinate.longitude, altitude: newPoint.altitude)
    }
    
    func flushPoints() {
        pthread_mutex_lock(&mutex)
        defer {
            pthread_mutex_unlock(&mutex)
        }
        
        let databaseManager = LFDatabaseManager.sharedManager()
        databaseManager.savePath(bufferPath, completion: {
            success in
            
            if !success {
                self.flushPoints()
            }
        })
    }
}
