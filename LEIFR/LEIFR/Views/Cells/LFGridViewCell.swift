//
//  LFGridViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFGridViewCell: LFCollectionViewCell {
	@IBOutlet var imageView: UIImageView!
	
	var representedAssetIdentifier: String!
	
	var thumbnailImage: UIImage! {
		didSet {
			imageView.image = thumbnailImage
		}
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		imageView.image = nil
	}
}
