//
//  LFCollectionViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	static var identifier: String {
		get {
			return String(describing: self)
		}
	}

	class func registerCell(collectionView: UICollectionView, reuseIdentifier: String) {
		let nibName = String(describing: self)
		let nib = UINib(nibName: nibName, bundle: Bundle.main)
		collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
	}
}
