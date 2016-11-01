//
//  LFButtonCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 1/11/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFButtonCell: LFTableViewCell {

	@IBOutlet var buttonView: UIView!
	@IBOutlet var buttonTitleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.configureCellAppearance()
    }
	
	fileprivate func configureCellAppearance() {
		let layer = self.buttonView.layer
		layer.cornerRadius = 5
		layer.shadowRadius = 3
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.05
		layer.shadowOffset = CGSize.zero
		
		self.selectionStyle = .none
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		if highlighted {
			self.buttonView.alpha = 0.2
		} else {
			let duration = 0.5
			UIView.animate(withDuration: duration, animations: {
				self.buttonView.alpha = 1
			})
		}
	}
}
