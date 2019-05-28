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
	var progressNotificationName: String!
	var completionNotificationName: String!
	var updateInProgress = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.progressView.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let center = NotificationCenter.default
        let startingDate = Date()
		
		center.addObserver(forName: NSNotification.Name(rawValue: progressNotificationName), object: nil, queue: nil, using: {
			notification in
			if !self.updateInProgress {
				self.updateInProgress = true
				if let progress = (notification.userInfo as? [String: CGFloat])?["progress"] {
					DispatchQueue.main.async {
//                        所需时间成几何级增长
//                        testing result:
//                        1.12842601537704
//                        2.32507395744324
//                        5.11427700519562
//                        11.7953410148621
//                        36.2655509710312
//                        77.3947529792786
//                        237.614533007145
//                        526.361443996429
                        let interval = 0.1
						self.progressView.setProgress(value: progress, animationDuration: interval, completion: {
							self.updateInProgress = false
						})
					}
				}
			}
		})
		
		center.addObserver(forName: NSNotification.Name(rawValue: completionNotificationName), object: nil, queue: nil, using: {
			notification in
			DispatchQueue.main.async {
				self.progressView.setProgress(value: self.progressView.maxValue, animationDuration: 1, completion: {
					DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
						self.dismiss(animated: true, completion: nil)
					})
				})
			}
		})
	}
}

extension LFLoadingViewController: UICircularProgressRingDelegate {
    func finishedUpdatingProgress(forRing ring: UICircularProgressRingView) {
        
    }
}
