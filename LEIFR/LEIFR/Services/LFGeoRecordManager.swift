//
//  LFGeoRecordManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFGeoRecordManager: NSObject {
    fileprivate static let manager = LFGeoRecordManager()
    fileprivate var bufferPath = LFPath()
    fileprivate var mutex = pthread_mutex_t()
    
    public private(set) var isRecording = false
    
    class func sharedManager() -> LFGeoRecordManager {
        return self.manager
    }
    
    func recordPoint(_ newPoint: CLLocation) {
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
        
        if self.bufferPath.points().count > 0 {
            let databaseManager = LFDatabaseManager.shared
            databaseManager.savePath(self.bufferPath, completion: {
                success in
                
                if !success {
                    self.flushPoints()
                }
            })
        }
    }
    
    func startRecording() {
        self.isRecording = true
    }
    
    func stopRecording() {
        self.flushPoints()
        self.isRecording = false
    }
}
