//
//  LFFlagViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 2/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFFlagViewController: LFViewController {
	
	var countries = [[LFCachedCountry]]()
	var displayIndex = 0
	fileprivate var gridSpacing: CGFloat = 2
	
	@IBOutlet var collectionView: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setup(collectionView: self.collectionView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let indexPath = IndexPath(item: displayIndex, section: 0)
		self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
	}
	
	fileprivate var gridItemSize: CGFloat {
		get {
			let width = collectionView.bounds.width
			let numberOfItemsPerRow: CGFloat = 3
			let sideLength = (width - (numberOfItemsPerRow - 1) * gridSpacing) / numberOfItemsPerRow
			return sideLength
		}
	}
}


extension LFFlagViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	fileprivate func setup(collectionView: UICollectionView) {
		collectionView.dataSource = self
		collectionView.delegate = self
		collectionView.contentInset = UIEdgeInsets(top: 84 + gridSpacing, left: 0, bottom: 200 + gridSpacing, right: 0)
		collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 84, left: 0, bottom: 64, right: 0)
		LFFlagCollectionViewCell.registerCell(collectionView: collectionView, reuseIdentifier: String(describing: LFFlagCollectionViewCell.self))
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let country = countries[indexPath.section][indexPath.row]
		let region = APReverseGeocoding.default().regionForCountry(withCode: country.code)
		let controller = LFMapPreviewViewController.controllerFromStoryboard() as! LFMapPreviewViewController
		controller.startRegion = region
		self.present(controller, animated: true, completion: nil)
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return countries.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return countries[section].count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let country = countries[indexPath.section][indexPath.row]
		
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LFFlagCollectionViewCell.self), for: indexPath) as? LFFlagCollectionViewCell
			else {
				fatalError("unexpected cell in collection view")
		}

		cell.nameLabel.text = country.localizedName()
		cell.flagImageView.image = UIImage(named: country.twoDigitCountryCode())
		cell.setActive(active: country.visited)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.gridItemSize, height: self.gridItemSize)
	}
}

extension LFFlagViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFFlagViewController") as! LFViewController
		controller.modalTransitionStyle = .crossDissolve
		return controller
	}
}
