//
//  LFInboxTableViewCell.swift
//  LEIFR
//
//  Created by Jinghan Wang on 18/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFInboxTableViewCell: LFTableViewCell {

	fileprivate static let mapPlaceHolderImage = #imageLiteral(resourceName: "map-placeholder")
	fileprivate static var intervalFormatter = DateIntervalFormatter()
	
	@IBOutlet var mapImageView: UIImageView!
	@IBOutlet var primaryLabel: UILabel!
	@IBOutlet var secondaryLabel: UILabel!
	
	fileprivate var mapPathColor = UIColor(white: 0, alpha: 0.3)
	fileprivate var mapPathLineWidth: CGFloat = 10
	fileprivate let snapOptions = MKMapSnapshotOptions()
	var incomingPath: LFIncomingPath! {
		didSet {
			self.path = incomingPath.path
		}
	}
	
	fileprivate var path: LFPath! {
		didSet {
			updateMapImage()
			updateTexts()
		}
	}
	
	var indexPath = IndexPath() {
		didSet {
			self.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clear : UIColor(white: 1, alpha: 0.1)
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		snapOptions.scale = UIScreen.main.scale
		snapOptions.showsBuildings = false
		snapOptions.showsPointsOfInterest = false
		snapOptions.size = self.mapImageView.bounds.size
		
		mapImageView.image = LFInboxTableViewCell.mapPlaceHolderImage
		
		updateMapImage()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		// Configure the view for the selected state
	}
	
	fileprivate func updateTexts() {
		var timeString = ""
		if let interval = path.interval {
			timeString = LFInboxTableViewCell.intervalFormatter.string(from: interval)! + " · "
		}
		self.primaryLabel.text = incomingPath.fileName
		self.secondaryLabel.text = timeString + path.startingCountry
	}
	
	fileprivate func updateMapImage() {
		if let path = self.path {
			if let thumbnail = path.thumbnail {
				self.mapImageView.image = thumbnail
				return
			}
			
			if let region = path.boundedRegion {
				snapOptions.region = region
			}
			
			let snapShotter = MKMapSnapshotter(options: self.snapOptions)
			snapShotter.start(completionHandler: {
				optionalSnapShot, _ in
				DispatchQueue(label: "ImageProcessQueue").async {
					if let snapShot = optionalSnapShot {
						let image = self.imageByDrawPath(path: self.path, on: snapShot)
						self.path.thumbnail = image
						DispatchQueue.main.async {
							UIView.transition(with: self.mapImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
								self.mapImageView.image = image
							}, completion: nil)
						}
					}
				}
			})
		}
	}
	
	fileprivate func imageByDrawPath(path: LFPath, on mapSnapShot: MKMapSnapshot) -> UIImage {
		var image = mapSnapShot.image
		
		UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
		image.draw(at: CGPoint.zero)
		
		if let context = UIGraphicsGetCurrentContext() {
			context.setStrokeColor(mapPathColor.cgColor)
			context.setLineWidth(mapPathLineWidth)
			context.setLineCap(.round)
			context.setLineJoin(.round)
			context.beginPath()
			var isFirstPoint = true
			for point in path.points {
				let coordinate = point.coordinate
				let drawPoint = mapSnapShot.point(for: coordinate)
				if isFirstPoint {
					isFirstPoint = false
					context.move(to: drawPoint)
				} else {
					context.addLine(to: drawPoint)
				}
			}
			context.strokePath()
			if let result = UIGraphicsGetImageFromCurrentImageContext() {
				image = result
			}
			UIGraphicsEndImageContext()
		}
		
		return image
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		mapImageView.image = LFInboxTableViewCell.mapPlaceHolderImage
	}

}
