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

	var asset: PHAsset!
	
	@IBOutlet var collectionView: UICollectionView!
	
	@IBOutlet var imageView: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		let size = UIScreen.main.bounds.size
//		let scale = UIScreen.main.scale
//		let targetImageSize = CGSize(width: size.width * scale, height: size.height * scale)
//		LFPhotoManager.shared.getFullImageForAsset(asset: self.asset, size: targetImageSize, completion: {
//			image in
//			DispatchQueue.main.async {
//				self.imageView.image = image
//			}
//		})
//		
//		let layer = self.imageView.layer
//		layer.shadowColor = UIColor.black.cgColor
//		layer.shadowOffset = CGSize(width: 0, height: 0)
//		layer.shadowOpacity = 0.15
//		layer.shadowRadius = 3
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

extension LFPhotoDetailViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFPhotoDetailViewController") as! LFViewController
		controller.modalTransitionStyle = .crossDissolve
		return controller
	}
}
