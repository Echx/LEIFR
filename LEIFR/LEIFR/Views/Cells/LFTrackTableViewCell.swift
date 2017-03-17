//
//  LFTrackTableViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 17/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import Mapbox

class LFTrackTableViewCell: LFTableViewCell {
	
	private static let mapPlaceHolderImage = #imageLiteral(resourceName: "map-placeholder")
	
	@IBOutlet var mapImageView: UIImageView!
	fileprivate let snapOptions = MKMapSnapshotOptions()
	var path: LFPath! {
		didSet {
			updateMapImage()
		}
	}
	
	var indexPath = IndexPath() {
		didSet {
			self.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clear : UIColor(white: 1, alpha: 0.2)
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		snapOptions.scale = UIScreen.main.scale
		snapOptions.showsBuildings = false
		snapOptions.showsPointsOfInterest = false
		snapOptions.size = self.mapImageView.bounds.size
		
		mapImageView.image = LFTrackTableViewCell.mapPlaceHolderImage
		
		updateMapImage()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
	fileprivate func updateMapImage() {
		if let path = self.path {
			if let region = path.boundedRegion {
				snapOptions.region = region
			}
		}
		
		let snapShotter = MKMapSnapshotter(options: snapOptions)
		snapShotter.start(completionHandler: {
			snapShot, _ in
			UIView.transition(with: self.mapImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
				self.mapImageView.image = snapShot?.image
			}, completion: nil)
		})
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		mapImageView.image = LFTrackTableViewCell.mapPlaceHolderImage
	}
}
