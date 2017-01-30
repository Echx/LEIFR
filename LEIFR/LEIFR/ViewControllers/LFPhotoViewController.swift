//
//  LFPhotoViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import Photos

private extension UICollectionView {
	func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
		let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
		return allLayoutAttributes.map { $0.indexPath }
	}
}

class LFPhotoViewController: LFViewController {
	
	@IBOutlet var collectionView: UICollectionView!
	
	fileprivate var gridSpacing: CGFloat = 2
	
	fileprivate var fetchResult = PHFetchResult<PHAsset>()
	fileprivate let imageManager = PHCachingImageManager()
	fileprivate var thumbnailSize: CGSize!
	fileprivate var previousPreheatRect = CGRect.zero

    override func viewDidLoad() {
        super.viewDidLoad()
		self.collectionView.alpha = 0
		DispatchQueue(label: "background").async {
			self.fetchResult = LFPhotoManager.shared.fetchAllAssets()
			DispatchQueue.main.async {
				self.collectionView.reloadData()
				let indexPath = IndexPath(item: self.fetchResult.count - 1, section: 0)
				self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
				UIView.animate(withDuration: 0.2, animations: {
					self.collectionView.alpha = 1
				})
			}
		}
		self.setupCollectionView()
		
		PHPhotoLibrary.shared().register(self)
    }
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		let scale = UIScreen.main.scale
		self.thumbnailSize = CGSize(width: self.gridItemSize * scale, height: self.gridItemSize * scale)
		super.viewWillAppear(animated)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateCachedAssets()
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		updateCachedAssets()
	}

	fileprivate func resetCachedAssets() {
		imageManager.stopCachingImagesForAllAssets()
		previousPreheatRect = .zero
	}
	
	fileprivate func updateCachedAssets() {
		// Update only if the view is visible.
		guard isViewLoaded && view.window != nil else { return }
		
		// The preheat window is twice the height of the visible rect.
		let preheatRect = view!.bounds.insetBy(dx: 0, dy: -0.5 * view!.bounds.height)
		
		// Update only if the visible area is significantly different from the last preheated area.
		let delta = abs(preheatRect.midY - previousPreheatRect.midY)
		guard delta > view.bounds.height / 3 else { return }
		
		// Compute the assets to start caching and to stop caching.
		let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
		let addedAssets = addedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.map { indexPath in fetchResult.object(at: indexPath.item) }
		let removedAssets = removedRects
			.flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
			.map { indexPath in fetchResult.object(at: indexPath.item) }
		
		// Update the assets the PHCachingImageManager is caching.
		imageManager.startCachingImages(for: addedAssets,
		                                targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
		imageManager.stopCachingImages(for: removedAssets,
		                               targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
		
		// Store the preheat rect to compare against in the future.
		previousPreheatRect = preheatRect
	}
	
	fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
		if old.intersects(new) {
			var added = [CGRect]()
			if new.maxY > old.maxY {
				added += [CGRect(x: new.origin.x, y: old.maxY,
				                 width: new.width, height: new.maxY - old.maxY)]
			}
			if old.minY > new.minY {
				added += [CGRect(x: new.origin.x, y: new.minY,
				                 width: new.width, height: old.minY - new.minY)]
			}
			var removed = [CGRect]()
			if new.maxY < old.maxY {
				removed += [CGRect(x: new.origin.x, y: new.maxY,
				                   width: new.width, height: old.maxY - new.maxY)]
			}
			if old.minY < new.minY {
				removed += [CGRect(x: new.origin.x, y: old.minY,
				                   width: new.width, height: new.minY - old.minY)]
			}
			return (added, removed)
		} else {
			return ([new], [old])
		}
	}
	
	fileprivate var gridItemSize: CGFloat {
		get {
			let width = collectionView.bounds.width
			let numberOfItemsPerRow: CGFloat = 4
			let sideLength = (width - (numberOfItemsPerRow - 1) * gridSpacing) / numberOfItemsPerRow
			return sideLength
		}
	}
}

// MARK: PHPhotoLibraryChangeObserver
extension LFPhotoViewController: PHPhotoLibraryChangeObserver {
	func photoLibraryDidChange(_ changeInstance: PHChange) {
		
		guard let changes = changeInstance.changeDetails(for: fetchResult)
			else { return }
		
		// Change notifications may be made on a background queue. Re-dispatch to the
		// main queue before acting on the change as we'll be updating the UI.
		DispatchQueue.main.sync {
			// Hang on to the new fetch result.
			fetchResult = changes.fetchResultAfterChanges
			if changes.hasIncrementalChanges {
				// If we have incremental diffs, animate them in the collection view.
				guard let collectionView = self.collectionView else { fatalError() }
				collectionView.performBatchUpdates({
					// For indexes to make sense, updates must be in this order:
					// delete, insert, reload, move
					if let removed = changes.removedIndexes, removed.count > 0 {
						collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
					}
					if let inserted = changes.insertedIndexes, inserted.count > 0 {
						collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
					}
					if let changed = changes.changedIndexes, changed.count > 0 {
						collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
					}
					changes.enumerateMoves { fromIndex, toIndex in
						collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
						                        to: IndexPath(item: toIndex, section: 0))
					}
				})
			} else {
				// Reload the collection view if incremental diffs are not available.
				collectionView!.reloadData()
			}
			resetCachedAssets()
		}
	}
}

extension LFPhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	fileprivate func setupCollectionView() {
		self.collectionView.dataSource = self
		self.collectionView.delegate = self
		self.collectionView.contentInset = UIEdgeInsets(top: 84 + gridSpacing, left: 0, bottom: 64 + gridSpacing, right: 0)
		self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 84, left: 0, bottom: 64, right: 0)
		LFGridViewCell.registerCell(collectionView: self.collectionView, reuseIdentifier: String(describing: LFGridViewCell.self))
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let index = indexPath.item
		let asset = self.fetchResult[index]
		let photoDetailViewController = LFPhotoDetailViewController.defaultControllerFromStoryboard() as! LFPhotoDetailViewController
		photoDetailViewController.asset = asset
		self.present(photoDetailViewController, animated: true, completion: nil)
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
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LFGridViewCell.self), for: indexPath) as? LFGridViewCell
			else { fatalError("unexpected cell in collection view") }
		
		// Request an image for the asset from the PHCachingImageManager.
		cell.representedAssetIdentifier = asset.localIdentifier
		imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
			if cell.representedAssetIdentifier == asset.localIdentifier {
				cell.thumbnailImage = image
			}
		})
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.gridItemSize, height: self.gridItemSize)
	}
}

extension LFPhotoViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFPhotoViewController") as! LFViewController
		
		return controller
	}
}
