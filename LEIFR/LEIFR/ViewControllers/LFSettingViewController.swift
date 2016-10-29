//
//  LFSettingViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFSettingViewController: LFViewController {

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

// MARK: IBActions

extension LFSettingViewController {
	@IBAction func reconstructDatabase(sender: Any?) {
		print("Reconstructing Database...")
	}
}

extension LFSettingViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFSettingViewController") as! LFViewController
		
		return controller
	}
}
