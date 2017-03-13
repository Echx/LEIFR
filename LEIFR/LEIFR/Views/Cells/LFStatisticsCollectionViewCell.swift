//
//  LFStatisticsCollectionViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 13/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFStatisticsCollectionViewCell: LFCollectionViewCell {

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var seperator: UIView!
	@IBOutlet var label: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		let layer = self.layer
		layer.cornerRadius = 5
		layer.borderWidth = 5
		layer.borderColor = UIColor.white.cgColor
		layer.masksToBounds = false
    }
	
	func configurePrimaryColor(color: UIColor) {
		self.imageView.tintColor = color
		self.seperator.backgroundColor = color
		self.label.textColor = color
	}
	
	func configureSecondaryColor(color: UIColor) {
		self.backgroundColor = color
	}

}
