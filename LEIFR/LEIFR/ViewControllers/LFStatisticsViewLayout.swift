//
//  LFStatisticsViewLayout.swift
//  LEIFR
//
//  Created by Jinghan Wang on 14/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFStatisticsViewLayout: UICollectionViewFlowLayout {
	
	var mostRecentOffset : CGPoint = CGPoint()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.scrollDirection = .horizontal
		self.minimumLineSpacing = 15
		self.sectionInset = UIEdgeInsets(top: 0, left: 45, bottom: 0, right: 45)
	}
	
	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
		if velocity.x == 0 {
			return mostRecentOffset
		}
		
		if let cv = self.collectionView {
			
			let cvBounds = cv.bounds
			let halfWidth = cvBounds.size.width * 0.5;
			
			
			if let attributesForVisibleCells = self.layoutAttributesForElements(in: cvBounds) {
				
				var candidateAttributes : UICollectionViewLayoutAttributes?
				for attributes in attributesForVisibleCells {
					
					if attributes.representedElementCategory != UICollectionElementCategory.cell {
						continue
					}
					
					if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
						continue
					}
					candidateAttributes = attributes
				}
				
				if(proposedContentOffset.x == -(cv.contentInset.left)) {
					return proposedContentOffset
				}
				
				guard let _ = candidateAttributes else {
					return mostRecentOffset
				}
				mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
				return mostRecentOffset
				
			}
		}
		
		// fallback
		mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
		return mostRecentOffset
	}
}
