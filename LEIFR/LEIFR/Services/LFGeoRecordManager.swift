//
//  LFGeoRecordManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFGeoRecordManager: NSObject {
    static let shared = LFGeoRecordManager()
    fileprivate var bufferPath = LFPath()
    fileprivate var mutex = pthread_mutex_t()
    
    public private(set) var isRecording = false
    
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
        print("Flushing point..")
        if self.bufferPath.isValidPath() {
            let databaseManager = LFDatabaseManager.shared
            databaseManager.savePath(self.bufferPath, completion: {
                error in
                if error != nil {
					print(error!)
				} else {
					print("Path flushed")
					self.bufferPath = LFPath()
				}
            })
			
			databaseManager.getLatestTrackID(completion: {
				trackID in
				LFCachedDatabaseManager.shared.cachePath(with: trackID)
			})
		} else {
			print("Path did not survive validation, discarded")
		}
    }
    
    func startRecording() {
        self.isRecording = true
		print("GPS recording starts")
    }
    
    func stopRecording() {
        self.flushPoints()
        self.isRecording = false
		print("GPS recording ends")
    }
}
