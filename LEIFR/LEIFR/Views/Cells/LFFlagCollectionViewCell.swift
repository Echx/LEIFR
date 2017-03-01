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
	@IBOutlet weak var overlayView: UIView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.white
    }
	
	func setActive(active: Bool) {
		self.overlayView.alpha = active ? 0 : 0.8
	}
}
