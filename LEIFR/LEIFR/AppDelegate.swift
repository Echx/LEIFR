//
//  AppDelegate.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import FontBlaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    let locationManager = CLLocationManager()
    fileprivate let geoRecordManager = LFGeoRecordManager.sharedManager()
    fileprivate let databaseManager = LFDatabaseManager.sharedManager()


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		spatialite_init(1)
        configureLocationManager()
		FontBlaster.blast()
		
//		let databaseDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//		let array = try! FileManager.default.contentsOfDirectory(atPath: databaseDirectory)
		
//		for name in array {
//			if name != "default.sqlite" {
//				try! FileManager.default.removeItem(atPath: "\(databaseDirectory)/\(name)")
//			}
//		}
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let _ = self.databaseManager.closeDatabase()
        self.geoRecordManager.flushPoints()
	}

    fileprivate func configureLocationManager() {
        if self.databaseManager.openDatabase() {
            self.locationManager.delegate = self
            
            if self.locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
                self.locationManager.requestAlwaysAuthorization()
            }
            
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            
            Timer.scheduledTimer(timeInterval: 600, target: self.geoRecordManager, selector: #selector(LFGeoRecordManager.flushPoints), userInfo: nil, repeats: true)
        } else {
            print("location manager configuration failed")
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if geoRecordManager.isRecording {
            geoRecordManager.recordPoint(locations.last!)
        }
    }
}
