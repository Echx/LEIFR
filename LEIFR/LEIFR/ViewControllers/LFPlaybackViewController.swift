//
//  LFPlaybackViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import wkb_ios

class LFPlaybackViewController: LFViewController {
    
    fileprivate var paths: [LFPath]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadMapData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadMapData() {
        LFDatabaseManager.shared.getAllPaths { paths in
            
            
            print(paths.count) // 336
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let start = formatter.date(from: "2016/08/01")!
            let end = formatter.date(from: "2016/09/09")!
            
            self.paths = paths.filter {
                $0.isOverlappedWith(startDate: start, endDate: end)
            }
            
            print(self.paths?.count)
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

extension LFPlaybackViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFPlaybackViewController") as! LFViewController
		
		return controller
	}
}
