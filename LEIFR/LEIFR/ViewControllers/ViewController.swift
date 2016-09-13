//
//  ViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import Mapbox

class ViewController: UIViewController {
    @IBOutlet fileprivate weak var mapView: MGLMapView!
    
    fileprivate var coordinates: [CLLocationCoordinate2D]?

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
        self.mapView.delegate = self
    }
}

extension ViewController: MGLMapViewDelegate {
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        let databaseManager = LFDatabaseManager.sharedManager()
        let visibleBounds = mapView.visibleCoordinateBounds
        let visibleLongSpan = abs(visibleBounds.ne.longitude - visibleBounds.sw.longitude)
        let visibleLatSpan = abs(visibleBounds.ne.latitude - visibleBounds.sw.latitude)
        databaseManager.getPathsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), completion: {
            paths in
            if let path = paths.first {
                let points = path.points()
                if points.count != self.coordinates?.count {
                    if let existingAnnotations = mapView.annotations {
                        mapView.removeAnnotations(existingAnnotations)
                    }
                    self.coordinates = points.map({ (point) -> CLLocationCoordinate2D in
                        let wkbPoint = point as! WKBPoint
                        return CLLocationCoordinate2DMake(wkbPoint.latitude, wkbPoint.longitude)
                    })
                    
                    self.mapView.addAnnotation(MGLPolyline(coordinates: &self.coordinates!, count: UInt(self.coordinates!.count)))
                }
            }
        })
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 10.0
    }
}
