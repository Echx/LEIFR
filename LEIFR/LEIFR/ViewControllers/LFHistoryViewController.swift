//
//  LFHistoryViewController.swift
//  LEIFR
//
//  Created by Lei Mingyu on 20/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFHistoryViewController: LFViewController {
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    @IBOutlet weak var recordButton: LFRecordButton!
    @IBOutlet weak var recordButtonContent: UIView!
    
    fileprivate var overlay: MKOverlay?
	fileprivate var overlayRenderer: LFGeoPointsOverlayRenderer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureMap()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: basic configuration
    fileprivate func configureMap() {
        mapView.delegate = self
		
		let overlay = LFGeoPointsOverlay()
		self.mapView.add(overlay)
    }
}

extension LFHistoryViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is LFGeoPointsOverlay {
			if self.overlayRenderer == nil {
				self.overlayRenderer = LFGeoPointsOverlayRenderer(overlay: overlay)
			}
			
			return self.overlayRenderer
		} else {
			return MKOverlayRenderer(overlay: overlay)
		}
	}
}


extension LFHistoryViewController {
    override func controlViewForTab() -> UIView? {
        let view = Bundle.main.loadNibNamed("LFHistoryControlView", owner: self, options: nil)![0] as? UIView
        configureControlView()
        return view
    }
    
    fileprivate func configureControlView() {
		self.recordButton.setButtonContent(contentView: self.recordButtonContent)
        self.recordButton.delegate = self
    }
	
    @IBAction func toggleRecordButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func toggleUserLocation(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.mapView.showsUserLocation = !self.mapView.showsUserLocation
    }
    
    override func accessoryViewForTab() -> UIView? {
        return nil
    }
    
    override func accessoryTextForTab() -> String? {
        return "\"We are all leaders: whether we want to be or not. There is always someone we are influencing, either leading them to good or away from good.\""
    }
}

extension LFHistoryViewController: LFStoryboardBasedController {
    class func defaultControllerFromStoryboard() -> LFViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LFHistoryViewController") as! LFViewController
        
        return controller
    }
}

extension LFHistoryViewController: LFRecordButtonDelegate {
    func button(_ button: LFRecordButton, isForceTouchedWithForce force: CGFloat) {
        print(force)
        // TODO animation
    }
}
