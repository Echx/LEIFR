//
//  LFHoverTabBaseController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

protocol LFHoverTabBarDataSource {
	func controlViewForTab() -> UIView?
	func accessoryViewForTab() -> UIView?
	func accessoryTextForTab() -> String?
}

class LFHoverTabBaseController: LFViewController {

	static var defaultInstance: LFHoverTabBaseController!;
	
	@IBOutlet var tabView: UIView!
	@IBOutlet var tabViewTopConstraint: NSLayoutConstraint!
	
	@IBOutlet var containerView: UIView!
	fileprivate var tabControllers = [LFViewController]()
	fileprivate var currentTab = 1;
	
	private var tabViewSnapLevels: [CGFloat] = [UIScreen.main.bounds.height - 400, UIScreen.main.bounds.height - 200, UIScreen.main.bounds.height - 64]
	
	override func loadView() {
		LFHoverTabBaseController.defaultInstance = self
		super.loadView()
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(tabViewDidDrag(gesture:)))
		self.tabView.addGestureRecognizer(panGesture)
		self.tabViewTopConstraint.constant = self.tabViewSnapLevels.last!
		
		self.tabControllers = [
			LFHistoryViewController.defaultControllerFromStoryboard(),
			LFPlaybackViewController.defaultControllerFromStoryboard(),
			LFPhotoViewController.defaultControllerFromStoryboard(),
			LFSettingViewController.defaultControllerFromStoryboard()
		]
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
			let duration = TimeInterval(abs(self.tabViewTopConstraint.constant - snapLevel) / self.tabViewSnapLevels.last!) * 2
			self.tabViewTopConstraint.constant = snapLevel
			UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.allowUserInteraction, .allowAnimatedContent], animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	func switchToPage(index: Int) {
		if self.currentTab != index && index < self.tabControllers.count {
			let toController = self.tabControllers[index]
			let fromController = self.tabControllers[self.currentTab]
			
			toController.willMove(toParentViewController: self)
			
			
			//add new tab view
			let toView = toController.view!
			toView.translatesAutoresizingMaskIntoConstraints = false
			var newTabConstraints = [NSLayoutConstraint]()
			self.containerView.addSubview(toView)
			self.addChildViewController(toController)
			let viewBindings = ["toView" : toView]
			
			newTabConstraints.append(contentsOf: NSLayoutConstraint.constraints(
				withVisualFormat: "V:|-(0)-[toView]-(0)-|",
				options: [],
				metrics: nil,
				views: viewBindings)
			)
			
			newTabConstraints.append(contentsOf: NSLayoutConstraint.constraints(
				withVisualFormat: "H:|-(0)-[toView]-(0)-|",
				options: [],
				metrics: nil,
				views: viewBindings)
			)
			
			self.containerView.addConstraints(newTabConstraints)
			
			//remove original tab view
			fromController.view.removeFromSuperview()
			fromController.removeFromParentViewController()
			
			self.currentTab = index
			
			toController.didMove(toParentViewController: self)
		}
	}
}

extension LFHoverTabBaseController: LFHoverTabDelegate {
	func tabViewController(controller: LFViewController, tabDidSelectAtIndex index: Int) {
		print("Tab did select: \(index)")
		self.switchToPage(index: index)
	}
}

extension LFHoverTabBaseController: LFHoverTabDataSource {
	func accessoryTextForTab(atIndex index: Int) -> String? {
		return tabControllers[index].accessoryTextForTab()
	}

	func controlViewForTab(atIndex index: Int) -> UIView? {
		return tabControllers[index].controlViewForTab()
	}
	
	func accessoryViewForTab(atIndex index: Int) -> UIView? {
		return tabControllers[index].accessoryViewForTab()
	}
}
