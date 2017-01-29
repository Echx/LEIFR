//
//  LFPhotoManager.swift
//  LEIFR
//
//  Created by Jinghan Wang on 29/1/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import Photos

class LFPhotoManager: NSObject {
	static let shared = LFPhotoManager()
	let thumbnailSize = CGSize(width: 200, height: 200)
	let imageManager = PHCachingImageManager()
	
	func fetchAssets(from fromDate: Date, till endDate: Date) -> PHFetchResult<PHAsset> {
		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		fetchOptions.predicate = NSPredicate(format: "(creationDate >= %@) AND (creationDate <= %@) AND (mediaType == %ld) AND (mediaSubtype != %d)", fromDate as NSDate, endDate as NSDate, PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue)
		let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
		
		return fetchResult
	}
	
	func fetchAllAssets() -> PHFetchResult<PHAsset> {
		let fetchOptions = PHFetchOptions()
		fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
		fetchOptions.predicate = NSPredicate(format: "(creationDate != nil) AND (mediaType == %ld) AND (mediaSubtype != %d)", PHAssetMediaType.image.rawValue, PHAssetMediaSubtype.photoScreenshot.rawValue)
		let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
		return fetchResult
	}
	
	func startCachingAssets(fetchResult: PHFetchResult<PHAsset>, sizes: [CGSize]) {
		DispatchQueue(label: "image-caching-queue").async {
			var assets = [PHAsset]()
			fetchResult.enumerateObjects({
				(asset, _, _) in
				assets.append(asset)
			})
			
			let options = PHImageRequestOptions()
			options.resizeMode = .exact
			options.deliveryMode = .opportunistic
			for size in sizes {
				self.imageManager.startCachingImages(for: assets, targetSize: size, contentMode: .aspectFill, options: options)
			}
		}
	}
	
	func getImageForAsset(asset: PHAsset, size: CGSize, completion: @escaping ((UIImage?) -> Void)) {
		let options = PHImageRequestOptions()
		options.resizeMode = .exact
		options.deliveryMode = .opportunistic
		self.imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: {
			(result, _) in
			completion(result);
		})
	}
}

extension PHAsset {
	func thumbnail(completion: @escaping ((UIImage?) -> Void)) {
		let manager = LFPhotoManager.shared
		manager.getImageForAsset(asset: self, size: manager.thumbnailSize, completion: completion)
	}
}
