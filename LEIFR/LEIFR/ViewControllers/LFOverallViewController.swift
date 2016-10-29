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

	@IBOutlet weak var recordButton: LFRecordButton!
    @IBOutlet weak var recordButtonContent: UIView!
	
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
        self.mapView.showsUserLocation = true
    }
    
    // MARK: helper functions
    fileprivate func generateColorStops(minZoom: Int, maxZoom: Int, color: UIColor, bufferZoomLevel: Int) -> [Int: UIColor] {
        var result = [
            minZoom: color,
        ]
        
        if minZoom != maxZoom {
            result[maxZoom] = color
        }
        
        if minZoom > 0 {
            result[0] = UIColor.clear
        }
        
        if minZoom > bufferZoomLevel {
            result[minZoom - bufferZoomLevel] = UIColor.clear
        }
        
        if maxZoom < 22 {
            result[22] = UIColor.clear
        }
        
        if maxZoom < 22 - bufferZoomLevel {
            result[maxZoom + bufferZoomLevel] = UIColor.clear
        }
        
        return result
    }
}

extension LFOverallViewController: MGLMapViewDelegate {
	
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
		
        if mapView.zoomLevel > 12 {
            if mapView.style().layer(withIdentifier: "lf-point-layer") == nil {
                let source = MGLSource(sourceIdentifier: "symbol")!
                let symbolLayer = MGLSymbolStyleLayer(layerIdentifier: "place-city-sm", source: source)
                if self.pointSource != nil {
                    let pointLayer = MGLCircleStyleLayer(layerIdentifier: "lf-point-layer", source: self.pointSource!)
                    
                    let styleLayerColor = MGLStyleAttributeFunction()
                    styleLayerColor.stops = [0: UIColor.clear, 12: UIColor.clear, 14: Color.iron]
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
        let databaseManager = LFDatabaseManager.shared
        let visibleBounds = mapView.visibleCoordinateBounds
        let visibleLongSpan = abs(visibleBounds.ne.longitude - visibleBounds.sw.longitude)
        let visibleLatSpan = abs(visibleBounds.ne.latitude - visibleBounds.sw.latitude)
        
        let source = MGLSource(sourceIdentifier: "symbol")!
        let symbolLayer = MGLSymbolStyleLayer(layerIdentifier: "place-city-sm", source: source)
        
        let preloadPointsOptions = [["gridSize": 0.15, "stops": generateColorStops(minZoom: 0, maxZoom: 2, color: Color.iron, bufferZoomLevel: 2)],
                                    ["gridSize": 0.05, "stops": generateColorStops(minZoom: 4, maxZoom: 5, color: Color.iron, bufferZoomLevel: 2)],
                                    ["gridSize": 0.02, "stops": generateColorStops(minZoom: 7, maxZoom: 8, color: Color.iron, bufferZoomLevel: 2)],
                                    ["gridSize": 0.005, "stops": generateColorStops(minZoom: 10, maxZoom: 11, color: Color.iron, bufferZoomLevel: 1)],
                                    ["gridSize": 0.002, "stops": generateColorStops(minZoom: 12, maxZoom: 12, color: Color.iron, bufferZoomLevel: 1)]]
        
        for (index, option) in preloadPointsOptions.enumerated() {
            databaseManager.getPointsGeoJSONInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: option["gridSize"] as! Double, completion: {
                pointsJSON in
                self.mapSourceProcessingQueue.async {
                    if let wrappedJSON = LFGeoJSONManager.wrapArray(geometryArray: pointsJSON) {
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
        
        databaseManager.getPointsGeoJSONInRegion(MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(visibleLatSpan, visibleLongSpan)), gridSize: 0.0005, completion: {
            pointsJSON in
            self.mapSourceProcessingQueue.async {
                if let wrappedJSON = LFGeoJSONManager.wrapArray(geometryArray: pointsJSON) {
                    self.pointSource = MGLGeoJSONSource(sourceIdentifier: "lf-point-source", geoJSONData: wrappedJSON.data(using: .utf8)!)
                    mapView.style().add(self.pointSource!)
                }
            }
        })
    }
}

extension LFOverallViewController {
	override func controlViewForTab() -> UIView? {
		let view = Bundle.main.loadNibNamed("LFHistoryControlView", owner: self, options: nil)![0] as? UIView
		self.configureControlView()
		return view
	}
	
	fileprivate func configureControlView() {
		let layer = self.recordButton.layer
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 8
		layer.cornerRadius = 48
        
        let contentLayer = self.recordButtonContent.layer
        contentLayer.cornerRadius = 35
        
        self.recordButton.delegate = self
	}
	
	@IBAction func recordButtonTouchDown(sender: UIButton) {
		self.recordButtonContent.alpha = 0.7
	}
	
	@IBAction func recordButtonTouchUp(sender: UIButton) {
		self.recordButtonContent.alpha = 1 
	}
	
	@IBAction func toggleRecordButton(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: [], animations: {
                self.recordButtonContent.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.recordButtonContent.layer.cornerRadius = 10
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.2, options: [], animations: {
                self.recordButtonContent.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.recordButtonContent.layer.cornerRadius = 35
            }, completion: nil)
        }
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

extension LFOverallViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFOverallViewController") as! LFViewController
		
		return controller
	}
}

extension LFOverallViewController: LFRecordButtonDelegate {
    func button(_ button: LFRecordButton, isForceTouchedWithForce force: CGFloat) {
        print(force)
        // TODO animation
    }
}
