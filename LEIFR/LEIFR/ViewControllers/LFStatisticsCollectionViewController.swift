//
//  LFStatisticsCollectionViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 13/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFStatisticsCollectionViewController: UICollectionViewController {

	fileprivate let topBarHeight: CGFloat = 80
	fileprivate let bottomBarHeight: CGFloat = 60
	fileprivate let spacing: CGFloat = 20
	fileprivate let marginHorizontal: CGFloat = 20
	
    override func viewDidLoad() {
        super.viewDidLoad()

		
		self.collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        self.registerCells()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	private func registerCells() {
		LFStatisticsCollectionViewCell.registerCell(collectionView: self.collectionView!, reuseIdentifier: LFStatisticsCollectionViewCell.identifier)
	}

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LFStatisticsCollectionViewCell.identifier, for: indexPath)
		
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}

extension LFStatisticsCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	private func itemSize() -> CGSize {
		let height = UIScreen.main.bounds.height - topBarHeight - bottomBarHeight - 2 * spacing
		let width = UIScreen.main.bounds.width - 2 * spacing - 2 * marginHorizontal
		return CGSize(width: width, height: height)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return self.itemSize()
	}
}
