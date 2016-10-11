//
//  LFHoverTabViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

protocol LFHoverTabDelegate {
	func tabViewController(controller: LFViewController, tabDidSelectAtIndex index: Int)
}

protocol LFHoverTabDataSource {
	func controlViewForTab(atIndex index: Int) -> UIView?
	func accessoryViewForTab(atIndex index: Int) -> UIView?
	func accessoryTextForTab(atIndex index: Int) -> String?
}

class LFHoverTabViewController: LFViewController {
	
    fileprivate let geoRecordManager = LFGeoRecordManager.sharedManager()
	var delegate: LFHoverTabDelegate?
	var dataSource: LFHoverTabDataSource?
	
	
    @IBOutlet fileprivate weak var tabButton0: UIButton!
	@IBOutlet fileprivate weak var tabButton1: UIButton!
	@IBOutlet fileprivate weak var tabButton2: UIButton!
	@IBOutlet fileprivate weak var tabButton3: UIButton!
	
	@IBOutlet fileprivate weak var controlView: UIView!
	@IBOutlet fileprivate weak var accessoryView: UIView!
	@IBOutlet fileprivate weak var accessoryTextLabel: UILabel!
	
	fileprivate var tabButtons = [UIButton]()
	fileprivate var currentTab = 1
	
	fileprivate var tabControlView: UIView?
	fileprivate var tabAccessoryView: UIView?
    
	override func loadView() {
		super.loadView()
		
		let layer = view.layer
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowPath = UIBezierPath(rect: CGRect(x: -5, y: 0, width: view.bounds.width + 10, height: view.bounds.height)).cgPath
		layer.shadowOpacity = 0.15
		layer.shadowRadius = 3
		
		self.delegate = LFHoverTabBaseController.defaultInstance
		self.dataSource = LFHoverTabBaseController.defaultInstance
		
		tabButtons = [tabButton0, tabButton1, tabButton2, tabButton3]
		
		self.buttonDidClick(sender: tabButton0)
		
	}
	
	@IBAction func buttonDidClick(sender: UIButton) {
		self.delegate?.tabViewController(controller: self, tabDidSelectAtIndex: sender.tag)
		self.loadControlViewForTab(atIndex: sender.tag)
		self.loadAccessoryViewForTab(atIndex: sender.tag)
		
		_ = tabButtons.map{$0.isSelected = false}
		
		sender.isSelected = true
		self.currentTab = sender.tag
	}
	
	func loadControlViewForTab(atIndex index: Int) {
		if self.currentTab != index && index < self.tabButtons.count {
			self.tabControlView?.removeFromSuperview()
			if let view = self.dataSource?.controlViewForTab(atIndex: index) {
				view.translatesAutoresizingMaskIntoConstraints = false
				var constraints = [NSLayoutConstraint]()
				let viewBindings = ["view" : view]
				
				self.controlView.addSubview(view)
				
				constraints.append(contentsOf: NSLayoutConstraint.constraints(
					withVisualFormat: "V:|-(0)-[view]-(0)-|",
					options: [],
					metrics: nil,
					views: viewBindings)
				)
				
				constraints.append(contentsOf: NSLayoutConstraint.constraints(
					withVisualFormat: "H:|-(0)-[view]-(0)-|",
					options: [],
					metrics: nil,
					views: viewBindings)
				)
				
				self.controlView.addConstraints(constraints)
				self.tabControlView = view
			}
		}
	}
	
	func loadAccessoryViewForTab(atIndex index: Int) {
		if (self.currentTab != index && index < self.tabButtons.count) {
			self.tabAccessoryView?.removeFromSuperview()
			if let view = self.dataSource?.accessoryViewForTab(atIndex: index) {
				self.accessoryTextLabel.isHidden = true
				view.translatesAutoresizingMaskIntoConstraints = false
				var constraints = [NSLayoutConstraint]()
				let viewBindings = ["view" : view]
				
				self.accessoryView.addSubview(view)
				
				constraints.append(contentsOf: NSLayoutConstraint.constraints(
					withVisualFormat: "V:|-(0)-[view]-(0)-|",
					options: [],
					metrics: nil,
					views: viewBindings)
				)
				
				constraints.append(contentsOf: NSLayoutConstraint.constraints(
					withVisualFormat: "H:|-(0)-[view]-(0)-|",
					options: [],
					metrics: nil,
					views: viewBindings)
				)
				
				self.accessoryView.addConstraints(constraints)
				self.tabAccessoryView = view
			} else if let accessoryText = self.dataSource?.accessoryTextForTab(atIndex: index) {
				self.accessoryTextLabel.isHidden = false
				self.accessoryTextLabel.text = accessoryText
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
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
