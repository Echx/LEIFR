//
//  LFHorizontalCollectionViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import Photos

class LFHorizontalCollectionViewCell: LFCollectionViewCell {

	var asset: PHAsset!
	@IBOutlet var tableView: UITableView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

extension LFHorizontalCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
}
