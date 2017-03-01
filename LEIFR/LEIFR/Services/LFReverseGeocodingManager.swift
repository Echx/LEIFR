//
//  LFReverseGeocodingManager.swift
//  LEIFR
//
//  Created by Jinghan Wang on 1/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import APOfflineReverseGeocoding

class LFReverseGeocodingManager: NSObject {
	
	static var shared = LFReverseGeocodingManager()
	fileprivate let reverseGeocodingQueue = OperationQueue()
	fileprivate let keyPathOperation = "operations"
	let queueJobsCompleteNotification = Notification(name: Notification.Name(rawValue: "ReverseGeocodingJobsComplete"))
	
	override init() {
		super.init()
		
		self.reverseGeocodingQueue.addObserver(self, forKeyPath: self.keyPathOperation, options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
	}
	
	func reverseGeocoding(coordinate: CLLocationCoordinate2D) {
		let databaseManager = LFCachedDatabaseManager.shared
		self.reverseGeocodingQueue.addOperation {
			if let result = APReverseGeocoding.default().geocodeCountry(with: coordinate) {
				databaseManager.updateCountryVisited(code: result.code)
			}
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		
		if let queue = object as? OperationQueue {
			guard queue == self.reverseGeocodingQueue else {
				return
			}
			
			guard queue.operations.count == 0 else {
				return
			}
			
			guard keyPath == self.keyPathOperation else {
				return
			}
			
			print("Reverse geocoding finished!")
			NotificationCenter.default.post(self.queueJobsCompleteNotification)
		}
	}
}
