//
//  LFFlagCollectionViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 2/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFFlagCollectionViewCell: LFCollectionViewCell {

	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var flagImageView: UIImageView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func setActive(active: Bool) {
		self.flagImageView.alpha = active ? 1 : 0.3
	}
}
