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
    
    fileprivate var pointLayer: MGLCircleStyleLayer?

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
        if mapView.zoomLevel > 13 {
            if mapView.style().layer(withIdentifier: "lf-point-layer") == nil {
                let source = MGLSource(sourceIdentifier: "symbol")!
                let symbolLayer = MGLSymbolStyleLayer(layerIdentifier: "place-city-sm", source: source)

                mapView.style().insert(self.pointLayer!, below: symbolLayer)
            }
        } else {
            if let _ = mapView.style().layer(withIdentifier: "lf-point-layer") {
                mapView.style().remove(self.pointLayer!)
            }
        }
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        let databaseManager = LFDatabaseManager.sharedManager()
        let visibleBounds = mapView.visibleCoordinateBounds
        let visibleLongSpan = abs(visibleBounds.ne.longitude - visibleBounds.sw.longitude)
        let visibleLatSpan = abs(visibleBounds.ne.latitude - visibleBounds.sw.latitude)
        
        let source = MGLSource(sourceIdentifier: "symbol")!
        let symbolLayer = MGLSymbolStyleLayer(layerIdentifier: "place-city-sm", source: source)

        
        databaseManager.getPointsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: 0.0005, completion: {
            pointsJSON in
            
            if let wrappedJSON = LFGeoJSONWrapper.wrapArray(geometryArray: pointsJSON) {
                let geoJSONSource = MGLGeoJSONSource(sourceIdentifier: "lf-point-source", geoJSONData: wrappedJSON.data(using: .utf8)!)
                mapView.style().add(geoJSONSource)
                
                self.pointLayer = MGLCircleStyleLayer(layerIdentifier: "lf-point-layer", source: geoJSONSource)
                self.pointLayer!.circleColor = UIColor.yellow
                self.pointLayer!.circleRadius = NSNumber(integerLiteral: 5)
            }
        })
        
        databaseManager.getPointsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: 0.01, completion: {
            pointsJSON in
            
            if let wrappedJSON = LFGeoJSONWrapper.wrapArray(geometryArray: pointsJSON) {
                let geoJSONSource = MGLGeoJSONSource(sourceIdentifier: "lf-point-source-0", geoJSONData: wrappedJSON.data(using: .utf8)!)
                mapView.style().add(geoJSONSource)

                let styleLayerColor = MGLStyleAttributeFunction()
                styleLayerColor.stops = [0: UIColor.red, 2: UIColor.red, 3: UIColor.clear]
                
                let styleLayer = MGLCircleStyleLayer(layerIdentifier: "lf-point-layer-0", source: geoJSONSource)
                styleLayer.circleColor = styleLayerColor
                styleLayer.circleRadius = NSNumber(integerLiteral: 5)
                mapView.style().insert(styleLayer, below: symbolLayer)
            }
        })
        
        databaseManager.getPointsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: 0.005, completion: {
            pointsJSON in
            
            if let wrappedJSON = LFGeoJSONWrapper.wrapArray(geometryArray: pointsJSON) {
                let geoJSONSource = MGLGeoJSONSource(sourceIdentifier: "lf-point-source-1", geoJSONData: wrappedJSON.data(using: .utf8)!)
                mapView.style().add(geoJSONSource)
                
                let styleLayerColor = MGLStyleAttributeFunction()
                styleLayerColor.stops = [0: UIColor.clear, 3: UIColor.clear, 4: UIColor.green, 7: UIColor.green, 8: UIColor.clear]
                
                let styleLayer = MGLCircleStyleLayer(layerIdentifier: "lf-point-layer-1", source: geoJSONSource)
                styleLayer.circleColor = styleLayerColor
                styleLayer.circleRadius = NSNumber(integerLiteral: 5)
                mapView.style().insert(styleLayer, below: symbolLayer)
            }
        })
        
        databaseManager.getPointsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: 0.002, completion: {
            pointsJSON in
            
            if let wrappedJSON = LFGeoJSONWrapper.wrapArray(geometryArray: pointsJSON) {
                let geoJSONSource = MGLGeoJSONSource(sourceIdentifier: "lf-point-source-2", geoJSONData: wrappedJSON.data(using: .utf8)!)
                mapView.style().add(geoJSONSource)
                
                let styleLayerColor = MGLStyleAttributeFunction()
                styleLayerColor.stops = [0: UIColor.clear, 8: UIColor.clear, 9: UIColor.blue, 12: UIColor.blue, 13: UIColor.clear]
                
                let styleLayer = MGLCircleStyleLayer(layerIdentifier: "lf-point-layer-2", source: geoJSONSource)
                styleLayer.circleColor = styleLayerColor
                styleLayer.circleRadius = NSNumber(integerLiteral: 5)
                mapView.style().insert(styleLayer, below: symbolLayer)
            }
        })
    }
}
