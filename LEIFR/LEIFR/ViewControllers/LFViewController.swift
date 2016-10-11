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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
