//
//  LFHistoryMapKitViewController.swift
//  LEIFR
//
//  Created by Lei Mingyu on 7/6/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFHistoryMapKitViewController: LFHistoryViewController {
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    fileprivate var overlay: MKOverlay!
    fileprivate var overlayRenderer: LFGeoPointsOverlayRenderer!
    fileprivate var currentPathOverlay: LFCurrentPathOverlay!
    fileprivate var currentPathOverlayRenderer: LFCurrentPathOverlayRenderer!
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

// MARK: control panel
extension LFHistoryMapKitViewController {
    @IBAction func toggleUserLocation(sender: UIButton) {
        if !isTrackingUserLocation && self.mapView.showsUserLocation {
            isTrackingUserLocation = true
        } else {
            sender.isSelected = !sender.isSelected
            mapView.showsUserLocation = !self.mapView.showsUserLocation
            isTrackingUserLocation = mapView.showsUserLocation;
        }
    }
}

extension LFHistoryMapKitViewController: MKMapViewDelegate {
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


extension LFHistoryMapKitViewController: LFStoryboardBasedController {
    class func defaultControllerFromStoryboard() -> LFViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LFHistoryMapKitViewController") as! LFViewController
        
        return controller
    }
}
