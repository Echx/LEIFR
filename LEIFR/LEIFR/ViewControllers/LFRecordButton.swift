//
//  LFRecordButton.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

protocol LFRecordButtonDelegate {
    func button(_ button: LFRecordButton, isForceTouchedWithForce force: CGFloat)
}

class LFRecordButton: UIButton {
    var delegate: LFRecordButtonDelegate?
	
	fileprivate var buttonContent: UIView?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let layer = self.layer
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 8
		layer.cornerRadius = 48
	}
	
	func setButtonContent(contentView: UIView) {
		self.buttonContent = contentView
		contentView.layer.cornerRadius = 35
	}
	
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        if traitCollection.forceTouchCapability == .available {
            self.delegate?.button(self, isForceTouchedWithForce: touch.force)
        }
    }
	
	override var isSelected: Bool {
		get {
			return super.isSelected
		}
		
		set(newValue) {
			super.isSelected = newValue
			if newValue {
				UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
					self.buttonContent?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
					self.buttonContent?.layer.cornerRadius = 10
				}, completion: nil)
			} else {
				UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
					self.buttonContent?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
					self.buttonContent?.layer.cornerRadius = 35
				}, completion: nil)
			}
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		self.buttonContent?.alpha = 0.5
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		self.buttonContent?.alpha = 1
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		self.buttonContent?.alpha = 1
	}
}
