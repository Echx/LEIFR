//
//  LFViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

protocol LFStoryboardBasedController {
	static func defaultControllerFromStoryboard() -> LFViewController
}

class LFViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func dismissWithAnimation() {
		self.dismiss(animated: true, completion: nil)
	}

	class func controllerFromStoryboard() -> LFViewController {
		let className = NSStringFromClass(self).components(separatedBy: ".").last!
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: className) as! LFViewController
		return controller
	}
}

extension LFViewController: LFHoverTabBarDataSource {
	func controlViewForTab() -> UIView? {
		return nil
	}
	
	func accessoryViewForTab() -> UIView? {
		return nil
	}
	
	func accessoryTextForTab() -> String? {
		return "Accessory view hasn't been implemented"
	}
}
