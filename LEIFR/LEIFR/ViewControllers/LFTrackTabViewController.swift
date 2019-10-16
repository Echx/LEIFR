//
//  LFTrackTabViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 18/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFTrackTabViewController: LFViewController {

    static var defaultInstance: LFTrackTabViewController!;
	
	fileprivate var tabControllers = [LFViewController]()
	fileprivate var currentTab = 1;
	@IBOutlet var containerView: UIView!
	@IBOutlet var tabBar: UIView!
	@IBOutlet var tabButtonLeft: UIButton!
	@IBOutlet var tabButtonRight: UIButton!
	fileprivate var tabButtons = [UIButton]()
	
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.configureTabBar()

		self.tabControllers = [
			LFMyTrackViewController.controllerFromStoryboard(),
			LFInboxViewController.controllerFromStoryboard()
		]
		
		self.tabButtons = [tabButtonLeft, tabButtonRight]
		
		self.switchToPage(index: 0)
    }

	fileprivate func configureTabBar() {
		let layer = tabBar.layer
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowPath = UIBezierPath(rect: CGRect(x: -5, y: 0, width: view.bounds.width + 10, height: view.bounds.height)).cgPath
		layer.shadowOpacity = 0.15
		layer.shadowRadius = 3
	}
	
	@IBAction func buttonDidClick(sender: UIButton) {
		self.switchToPage(index: sender.tag)
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
        
        self.updateButtonStatus()
	}
    
    private func updateButtonStatus() {
        for button in [self.tabButtonLeft, self.tabButtonRight] {
            button?.isSelected = button?.tag == self.currentTab
        }
    }
}
