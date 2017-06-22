//
//  LFHistoryViewController.swift
//  LEIFR
//
//  Created by Lei Mingyu on 20/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFHistoryViewController: LFViewController {
    @IBOutlet weak var recordButton: LFRecordButton!
    @IBOutlet weak var recordButtonContent: UIView!
	@IBOutlet weak var userLocationToggleButton: UIView!
    
    
    var isTrackingUserLocation = false {
		didSet {
			self.userLocationToggleButton.tintColor = isTrackingUserLocation ? UIColor.wetasphalt : UIColor.white
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: Control Panel
extension LFHistoryViewController {
    override func controlViewForTab() -> UIView? {
		let view = UIView.view(fromNib: "LFHistoryControlView", owner: self)
        configureControlView()
        return view
    }
	
    fileprivate func configureControlView() {
		recordButton.setButtonContent(contentView: recordButtonContent)
        recordButton.delegate = self
    }
	
    @IBAction func toggleUserLocation(sender: UIButton) {
        print("clicked")
    }
    
    @IBAction func toggleRecordButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
		
		if sender.isSelected {
			//start recording
			LFGeoRecordManager.shared.startRecording()
		} else {
			//end recording
			LFGeoRecordManager.shared.stopRecording()
		}
    }
	
	@IBAction func showAllTrackView(sender: UIButton) {
		self.present(LFTrackTabViewController.defaultInstance, animated: true, completion: nil)
	}
    
    override func accessoryTextForTab() -> String? {
        return "\"We are all leaders: whether we want to be or not. There is always someone we are influencing, either leading them to good or away from good.\""
    }
}

extension LFHistoryViewController: LFRecordButtonDelegate {
    func button(_ button: LFRecordButton, isForceTouchedWithForce force: CGFloat) {
        print(force)
        // TODO animation
    }
}
