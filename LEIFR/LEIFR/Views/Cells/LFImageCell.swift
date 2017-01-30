//
//  LFImageCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFImageCell: LFTableViewCell {
	
	@IBOutlet var mainImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.selectionStyle = .none
		
		let layer = self.mainImageView.layer
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowOpacity = 0.25
		layer.shadowRadius = 3
    }
	
	func adjustImageViewFrame(offset: CGFloat, maxOffset: CGFloat) {
		guard let imageSize = self.mainImageView.image?.size else {
			return
		}
		
		guard offset <= maxOffset else {
			return
		}
		
		let targetHeight = imageSize.height / imageSize.width * self.mainImageView.bounds.width
		let originalHeight = UIScreen.main.bounds.height - 84
		let currentHeight = (targetHeight - originalHeight) * offset / maxOffset + originalHeight
		let currentY = self.mainImageView.frame.maxY - currentHeight
		self.mainImageView.frame = CGRect(x: 0, y: currentY, width: self.bounds.width, height: currentHeight)
	}

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
