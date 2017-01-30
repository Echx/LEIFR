//
//  LFHorizontalCollectionViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import Photos

class LFHorizontalCollectionViewCell: LFCollectionViewCell {	
	fileprivate enum Section: Int {
		case image = 0
		case map, count
	}
	
	fileprivate enum SectionImageRow: Int {
		case image = 0
		case count
	}
	
	fileprivate enum SectionMapRow: Int {
		case map = 0
		case count
	}
	
	var asset: PHAsset!
	@IBOutlet var tableView: UITableView!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		self.setUp(tableView: self.tableView)
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		asset = nil
		tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.tableView.reloadData()
	}
}

extension LFHorizontalCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
	func setUp(tableView: UITableView) {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UIColor.clear
		LFImageCell.registerCell(tableView: tableView, reuseIdentifier: LFImageCell.identifier)
		tableView.contentInset = UIEdgeInsets(top: 84, left: 0, bottom: 0, right: 0)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.count.rawValue
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case Section.image.rawValue:
			return SectionImageRow.count.rawValue
			
		case Section.map.rawValue:
			return SectionMapRow.count.rawValue
			
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let section = indexPath.section
		let row = indexPath.row
		
		switch section {
		case Section.image.rawValue:
			switch row {
			case SectionImageRow.image.rawValue:
				return self.bounds.height - tableView.contentInset.top - tableView.contentInset.bottom
			default:
				return 0
			}
			
		case Section.map.rawValue:
			return 20
			
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LFImageCell.identifier, for: indexPath) as! LFImageCell

		let size = UIScreen.main.bounds.size
		let scale = UIScreen.main.scale
		let targetImageSize = CGSize(width: size.width * scale, height: size.height * scale)
		LFPhotoManager.shared.getFullImageForAsset(asset: self.asset, size: targetImageSize, completion: {
			image in
			DispatchQueue.main.async {
				cell.mainImageView.image = image
			}
		})
		
		return cell
	}
}
