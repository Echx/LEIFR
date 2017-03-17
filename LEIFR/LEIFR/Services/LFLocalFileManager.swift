//
//  LFLocalFileManager.swift
//  LEIFR
//
//  Created by Jinghan Wang on 18/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFLocalFileManager: NSObject {

	static var shared = LFLocalFileManager()
	
	var inboxDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/Inbox"
	
	func removeFile(at path: String) {
		try? FileManager.default.removeItem(atPath: path)
	}
	
	func getAllIncommingPaths() -> [LFIncomingPath] {
		
		var incomingPaths = [LFIncomingPath]()
		
		guard let contents = try? FileManager.default.contentsOfDirectory(atPath: inboxDirectory) else {
			return incomingPaths
		}
		
		for fileName in contents {
			let file = inboxDirectory + "/" + fileName
			if let path = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? LFPath {
				let incomingPath = LFIncomingPath()
				incomingPath.path = path
				incomingPath.url = file
				incomingPath.fileName = fileName
				incomingPaths.append(incomingPath)
			}
		}
		
		return incomingPaths
	}
	
	func handleIncomingFile(with url: URL) -> Bool {
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			while let presentedViewController = topController.presentedViewController {
				topController = presentedViewController
			}
			// Switch to 0 then 1 to force inbox view reload
			LFTrackTabViewController.defaultInstance.switchToPage(index: 0)
			LFTrackTabViewController.defaultInstance.switchToPage(index: 1)
			if topController != LFTrackTabViewController.defaultInstance {
				topController.present(LFTrackTabViewController.defaultInstance, animated: true, completion: nil)
			}
		}
		return true
	}
}
