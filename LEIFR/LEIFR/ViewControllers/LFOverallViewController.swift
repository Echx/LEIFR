//
//  ViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import Mapbox

class LFOverallViewController: LFViewController {
    @IBOutlet fileprivate weak var mapView: MGLMapView!
    
    fileprivate var pointSource: MGLGeoJSONSource?
	fileprivate var mapSourceProcessingQueue = DispatchQueue(label: "MAP_SOURCE_PROCESSING_QUEUE")

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

extension LFOverallViewController: MGLMapViewDelegate {
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        if mapView.zoomLevel > 13 {
            if mapView.style().layer(withIdentifier: "lf-point-layer") == nil {
                let source = MGLSource(sourceIdentifier: "symbol")!
                let symbolLayer = MGLSymbolStyleLayer(layerIdentifier: "place-city-sm", source: source)
                if self.pointSource != nil {
                    let pointLayer = MGLCircleStyleLayer(layerIdentifier: "lf-point-layer", source: self.pointSource!)
                    
                    let styleLayerColor = MGLStyleAttributeFunction()
                    styleLayerColor.stops = [0: UIColor.clear, 13: UIColor.clear, 14: Color.IRON]
                    pointLayer.circleColor = styleLayerColor
                    
                    let styleLayerRadius = MGLStyleAttributeFunction()
                    styleLayerRadius.stops = [0: NSNumber(integerLiteral: 5), 15: NSNumber(integerLiteral: 5), 22: NSNumber(integerLiteral: 35)]
                    pointLayer.circleRadius = styleLayerRadius
                    
                    mapView.style().insert(pointLayer, below: symbolLayer)
                }
            }
        } else {
            if let pointLayer = mapView.style().layer(withIdentifier: "lf-point-layer") {
                mapView.style().remove(pointLayer)
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
        
        let preloadPointsOptions = [["gridSize": 0.01, "stops": [0: Color.IRON, 2: Color.IRON, 4: UIColor.clear]],
                                    ["gridSize": 0.005, "stops": [0: UIColor.clear, 3: UIColor.clear, 4: Color.IRON, 7: Color.IRON, 9: UIColor.clear]],
                                    ["gridSize": 0.001, "stops": [0: UIColor.clear, 8: UIColor.clear, 9: Color.IRON, 12: Color.IRON, 14: UIColor.clear]]]
        
        for (index, option) in preloadPointsOptions.enumerated() {
            databaseManager.getPointsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: option["gridSize"] as! Double, completion: {
                pointsJSON in
                self.mapSourceProcessingQueue.async {
                    if let wrappedJSON = LFGeoJSONWrapper.wrapArray(geometryArray: pointsJSON) {
                        let geoJSONSource = MGLGeoJSONSource(sourceIdentifier: "lf-point-source-\(index)", geoJSONData: wrappedJSON.data(using: .utf8)!)
                        mapView.style().add(geoJSONSource)

                        let styleLayerColor = MGLStyleAttributeFunction()
                        styleLayerColor.stops = option["stops"] as! [NSNumber : UIColor]
                        
                        let styleLayer = MGLCircleStyleLayer(layerIdentifier: "lf-point-layer-\(index)", source: geoJSONSource)
                        styleLayer.circleColor = styleLayerColor
                        styleLayer.circleRadius = NSNumber(integerLiteral: 5)
                        
                        mapView.style().insert(styleLayer, below: symbolLayer)
                    }
                }
            })
        }
        
        databaseManager.getPointsInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: 0.0005, completion: {
            pointsJSON in
            self.mapSourceProcessingQueue.async {
                if let wrappedJSON = LFGeoJSONWrapper.wrapArray(geometryArray: pointsJSON) {
                    self.pointSource = MGLGeoJSONSource(sourceIdentifier: "lf-point-source", geoJSONData: wrappedJSON.data(using: .utf8)!)
                    mapView.style().add(self.pointSource!)
                }
            }
        })
    }
}

extension LFOverallViewController {
	override func controlViewForTab() -> UIView? {
		let view = UIView()
		
		return view
	}
	
	override func accessoryViewForTab() -> UIView? {
		return nil
	}
	
	override func accessoryTextForTab() -> String? {
		return "\"We are all leaders-whether we want to be or not. There is always someone we are influencing, either leading them to good or away from good.\""
	}
}

extension LFOverallViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFOverallViewController") as! LFViewController
		
		return controller
	}
}
