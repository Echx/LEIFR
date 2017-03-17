//
//  LFIncomingPath.swift
//  LEIFR
//
//  Created by Jinghan Wang on 18/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFIncomingPath: NSObject {
	var path: LFPath!
	var url: String!
	var fileName: String!
	
	func delete() {
		LFLocalFileManager.shared.removeFile(at: self.url)
	}
}
