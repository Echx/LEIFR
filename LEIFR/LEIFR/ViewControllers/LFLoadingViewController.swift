//
//  LFLoadingViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 2/11/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import UICircularProgressRing

class LFLoadingViewController: LFViewController {

	@IBOutlet var progressView: UICircularProgressRingView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.progressView.delegate = self
        // Do any additional setup after loading the view.
    }
}

extension LFLoadingViewController: UICircularProgressRingDelegate {
	func finishedUpdatingProgressFor(_ ring: UICircularProgressRingView) {
		self.dismiss(animated: true, completion: nil)
	}
}
