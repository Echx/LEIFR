//
//  LFMapPreviewViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 15/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import MapKit

class LFMapPreviewViewController: LFViewController {

	@IBOutlet var mapView: MKMapView!
	var startRegion: MKCoordinateRegion!
	
	fileprivate var overlay: MKOverlay!
	fileprivate var overlayRenderer: LFGeoPointsOverlayRenderer!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.mapView.setRegion(startRegion, animated: false)
		
		self.configureMapAppearance()
		self.configureMap()
    }
	
	fileprivate func configureMapAppearance() {
		let layer = self.mapView.layer
		layer.cornerRadius = 5
		layer.borderWidth = 5
		layer.borderColor = UIColor.white.cgColor
	}
	
	fileprivate func configureMap() {
		mapView.delegate = self
		overlay = LFGeoPointsOverlay()
		mapView.add(overlay, level: .aboveRoads)
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

extension LFMapPreviewViewController: MKMapViewDelegate {
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
