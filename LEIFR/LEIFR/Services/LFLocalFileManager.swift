//
//  LFLocalFileManager.swift
//  LEIFR
//
//  Created by Jinghan Wang on 18/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFLocalFileManager: NSObject {

	
	fileprivate func checkInboxFolder() {
		let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
		let documentsDirectory: AnyObject = paths[0] as AnyObject
		let dataPath = documentsDirectory.appendingPathComponent("Inbox")!
		
		do {
			try FileManager.default.createDirectory(atPath: dataPath.absoluteString, withIntermediateDirectories: false, attributes: nil)
		} catch let error as NSError {
			print(error.localizedDescription);
		}
	}
}
