//
//  LFPhotoDetailViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import Photos

class LFPhotoDetailViewController: LFViewController {

	var fetchResult = PHFetchResult<PHAsset>()
	var displayIndex = 0
	
	@IBOutlet var collectionView: UICollectionView!
	
	fileprivate let imageManager = PHCachingImageManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		

//		
//		let layer = self.imageView.layer
//		layer.shadowColor = UIColor.black.cgColor
//		layer.shadowOffset = CGSize(width: 0, height: 0)
//		layer.shadowOpacity = 0.15
//		layer.shadowRadius = 3
		
		self.setup(collectionView: self.collectionView)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LFPhotoDetailViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	fileprivate func setup(collectionView: UICollectionView) {
		collectionView.dataSource = self
		collectionView.delegate = self
		LFHorizontalCollectionViewCell.registerCell(collectionView: collectionView, reuseIdentifier: String(describing: LFHorizontalCollectionViewCell.self))
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return fetchResult.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let asset = fetchResult.object(at: indexPath.item)
		
		// Dequeue a GridViewCell.
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LFHorizontalCollectionViewCell.self), for: indexPath) as? LFHorizontalCollectionViewCell else {
			fatalError("unexpected cell in collection view")
		}
		
		cell.asset = asset
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return UIScreen.main.bounds.size
	}
}

extension LFPhotoDetailViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFPhotoDetailViewController") as! LFViewController
		controller.modalTransitionStyle = .crossDissolve
		return controller
	}
}
