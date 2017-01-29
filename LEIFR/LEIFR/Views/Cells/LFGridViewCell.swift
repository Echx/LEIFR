//
//  LFGridViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFGridViewCell: UICollectionViewCell {
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
	
	class func registerCell(collectionView: UICollectionView, reuseIdentifier: String) {
		let nibName = String(describing: LFGridViewCell.self)
		let nib = UINib(nibName: nibName, bundle: Bundle.main)
		collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
	}
}
