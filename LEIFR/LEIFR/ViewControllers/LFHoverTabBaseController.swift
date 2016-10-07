//
//  LFHoverTabBaseController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFHoverTabBaseController: LFViewController {

	@IBOutlet var tabView: UIView!
	@IBOutlet var tabViewTopConstraint: NSLayoutConstraint!
	private var tabViewSnapLevels: [CGFloat] = [UIScreen.main.bounds.height - 400, UIScreen.main.bounds.height - 200, UIScreen.main.bounds.height - 64]
	
	override func loadView() {
		super.loadView()
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(tabViewDidDrag(gesture:)))
		self.tabView.addGestureRecognizer(panGesture)
		self.tabViewTopConstraint.constant = self.tabViewSnapLevels.last!
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private var startY = CGFloat(0)
	private var startConstant = CGFloat(0)
	func tabViewDidDrag(gesture: UIPanGestureRecognizer) {
		
		switch gesture.state {
		case .began:
			self.tabViewTopConstraint.constant = tabView.layer.presentation()!.frame.origin.y
			self.tabView.layer.removeAllAnimations()
			startY = gesture.location(ofTouch: 0, in: self.view).y
			self.startConstant = self.tabViewTopConstraint.constant
			view.setNeedsLayout()
			
		case .changed:
			let newConstant = gesture.location(ofTouch: 0, in: self.view).y - startY + startConstant
			if newConstant > self.tabViewSnapLevels.first! && newConstant < self.tabViewSnapLevels.last! {
				self.tabViewTopConstraint.constant = newConstant
				view.setNeedsLayout()
			} else {
				let reference = newConstant < self.tabViewSnapLevels.first! ? self.tabViewSnapLevels.first! : self.tabViewSnapLevels.last!
				let difference = newConstant - reference
				self.tabViewTopConstraint.constant = reference + difference * 0.1
				view.setNeedsLayout()
			}
			
		default:
			//select snap level
			var final = self.tabViewTopConstraint.constant
			final = final + (final > startConstant ? 1 : -1) * 100
			var difference = CGFloat(Int.max)
			var nearest = -1;
			for (index, level) in self.tabViewSnapLevels.enumerated() {
				if abs(level - final) < difference {
					difference = abs(level - final)
					nearest = index
				}
			}
			
			let snapLevel = self.tabViewSnapLevels[nearest]
			let duration = TimeInterval(abs(self.tabViewTopConstraint.constant - snapLevel) / self.tabViewSnapLevels.last!) * 5
			self.tabViewTopConstraint.constant = snapLevel
			UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.allowUserInteraction, .allowAnimatedContent], animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
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
