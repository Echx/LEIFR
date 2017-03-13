//
//  LFStatisticsCollectionViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 13/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFStatisticsCollectionViewCell: LFCollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
		
		let layer = self.layer
		layer.cornerRadius = 5
		layer.shadowRadius = 3
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.05
		layer.shadowOffset = CGSize.zero
		layer.masksToBounds = false
    }

}
