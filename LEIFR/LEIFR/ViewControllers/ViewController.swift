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
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        let databaseManager = LFDatabaseManager.sharedManager()
        let visibleBounds = mapView.visibleCoordinateBounds
        let visibleLongSpan = abs(visibleBounds.ne.longitude - visibleBounds.sw.longitude)
        let visibleLatSpan = abs(visibleBounds.ne.latitude - visibleBounds.sw.latitude)
        
        
        databaseManager.getPointsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), completion: {
            pointsJson in
            
            print(pointsJson)
            // TODO: bind data with source
        })
        
        let source = MGLSource(sourceIdentifier: "symbol")!
        let symbolLayer = MGLSymbolStyleLayer(layerIdentifier: "place-city-sm", source: source)
        
        let url = Bundle.main.url(forResource: "test-multipoint", withExtension: "geojson")!
        let geoJSONSource = MGLGeoJSONSource(sourceIdentifier: "test-source", url: url)
        mapView.style().add(geoJSONSource)
        
        let styleLayer = MGLCircleStyleLayer(layerIdentifier: "test-layer", source: geoJSONSource)
        styleLayer.circleColor = UIColor(colorLiteralRed: 0.7, green: 0.2, blue: 0.2, alpha: 0.6)
        styleLayer.circleRadius = NSNumber(integerLiteral: 5)
        mapView.style().insert(styleLayer, below: symbolLayer)
    }
}
