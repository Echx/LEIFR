//
//  LFHoverTabViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

protocol LFHoverTabDelegate {
	func tabViewController(controller: LFViewController, tabDidSelectAtIndex index: Int);
}

class LFHoverTabViewController: LFViewController {
	
    fileprivate let geoRecordManager = LFGeoRecordManager.sharedManager()
	var delegate: LFHoverTabDelegate?
    @IBOutlet fileprivate weak var tabButton0: UIButton!
	@IBOutlet fileprivate weak var tabButton1: UIButton!
	@IBOutlet fileprivate weak var tabButton2: UIButton!
	@IBOutlet fileprivate weak var tabButton3: UIButton!
	fileprivate var tabButtons = [UIButton]()
    
	override func loadView() {
		super.loadView()
		
		let layer = view.layer
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowPath = UIBezierPath(rect: CGRect(x: -5, y: 0, width: view.bounds.width + 10, height: view.bounds.height)).cgPath
		layer.shadowOpacity = 0.15
		layer.shadowRadius = 3
		
		self.delegate = LFHoverTabBaseController.defaultInstance
		
		tabButtons = [tabButton0, tabButton1, tabButton2, tabButton3]
		
	}
	
	@IBAction func buttonDidClick(sender: UIButton) {
		self.delegate?.tabViewController(controller: self, tabDidSelectAtIndex: sender.tag)
		
		for button in tabButtons {
			button.isSelected = button == sender ? true : false
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
