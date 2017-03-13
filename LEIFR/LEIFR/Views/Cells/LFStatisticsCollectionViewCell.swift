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
	@IBOutlet var progressLabel: UILabel!
	
	var primaryColor: UIColor? {
		didSet {
			let color = primaryColor
			self.imageView.tintColor = color
			self.seperator.backgroundColor = color
			self.label.textColor = color
			self.progressLabel.textColor = color
		}
	}
	var secondaryColor: UIColor? {
		didSet {
			let color = secondaryColor
			self.backgroundColor = color
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		let layer = self.layer
		layer.cornerRadius = 5
		layer.borderWidth = 5
		layer.borderColor = UIColor.white.cgColor
		layer.masksToBounds = false
    }
	
	func updateProgress(done: Int, all: Int) {
		self.progressLabel.text = "\(done) / \(all)"
	}
}
