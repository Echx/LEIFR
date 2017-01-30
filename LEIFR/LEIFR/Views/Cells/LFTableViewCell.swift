//
//  LFTableViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 1/11/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	static var identifier: String {
		get {
			return String(describing: self)
		}
	}
	
	class func registerCell(tableView: UITableView, reuseIdentifier: String) {
		let nibName = String(describing: self)
		let nib = UINib(nibName: nibName, bundle: Bundle.main)
		tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
	}
	
}
