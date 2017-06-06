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
	@IBOutlet weak var userLocationToggleButton: UIView!
    
    fileprivate var overlay: MKOverlay!
	fileprivate var overlayRenderer: LFGeoPointsOverlayRenderer!
	fileprivate var currentPathOverlay: LFCurrentPathOverlay!
	fileprivate var currentPathOverlayRenderer: LFCurrentPathOverlayRenderer!
	fileprivate var isTrackingUserLocation = false {
		didSet {
			self.userLocationToggleButton.tintColor = isTrackingUserLocation ? UIColor.wetasphalt : UIColor.white
		}
	}
	fileprivate var pathOverlays = [MKPolyline]()

    override func viewDidLoad() {
        super.viewDidLoad()
        LFTrackTabViewController.defaultInstance = LFTrackTabViewController.controllerFromStoryboard() as! LFTrackTabViewController
        self.configureMap()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated);
		recordButton.isSelected = LFGeoRecordManager.shared.isRecording;
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: basic configuration
    fileprivate func configureMap() {
        mapView.delegate = self
		overlay = LFGeoPointsOverlay()
		currentPathOverlay = LFCurrentPathOverlay()
		mapView.add(overlay, level: .aboveRoads)
    }
}

extension LFHistoryViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is LFGeoPointsOverlay {
			if self.overlayRenderer == nil {
				self.overlayRenderer = LFGeoPointsOverlayRenderer(overlay: overlay)
			}
			
			return self.overlayRenderer
		} else if overlay is LFCurrentPathOverlay {
			if self.currentPathOverlayRenderer == nil {
				self.currentPathOverlayRenderer = LFCurrentPathOverlayRenderer(overlay: overlay)
			}
			
			return self.currentPathOverlayRenderer
		} else {
			return MKOverlayRenderer(overlay: overlay)
		}
	}
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		if isTrackingUserLocation {
			let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(0.05, 0.05))
			mapView.setRegion(region, animated: true)
		}
		
		if LFGeoRecordManager.shared.isRecording {
			self.currentPathOverlay.addCoordinate(coordinate: userLocation.coordinate)
			mapView.remove(self.currentPathOverlay)
			mapView.add(self.currentPathOverlay)
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		for touch in touches {
			let location = touch.location(in: self.mapView)
			if self.mapView.point(inside: location, with: event) {
				isTrackingUserLocation = false;
				break;
			}
		}
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
    
    @IBAction func toggleUserLocation(sender: UIButton) {
		if !isTrackingUserLocation && self.mapView.showsUserLocation {
			isTrackingUserLocation = true
		} else {
			sender.isSelected = !sender.isSelected
			mapView.showsUserLocation = !self.mapView.showsUserLocation
			isTrackingUserLocation = mapView.showsUserLocation;
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
