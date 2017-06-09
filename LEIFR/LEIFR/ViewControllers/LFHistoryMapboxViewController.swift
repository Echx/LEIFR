//
//  LFHistoryMapboxViewController.swift
//  LEIFR
//
//  Created by Lei Mingyu on 7/6/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import Mapbox

class LFHistoryMapboxViewController: LFHistoryViewController, MGLMapViewDelegate {
    @IBOutlet fileprivate weak var mapView: MGLMapView!
    
    let layerIdentifier = "pathLayer"
    let sourceIdentifier = "pathSource"
    var presentedLevel = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        loadLayer(withLevel: presentedLevel)
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        let newLevel = Int(mapView.zoomLevel) + 1
        if newLevel != presentedLevel {
            presentedLevel = newLevel
            loadLayer(withLevel: presentedLevel)
        }
    }
    
    private func loadLayer(withLevel level: Int) {
        if let oldLayer = mapView.style?.layer(withIdentifier: layerIdentifier) {
            mapView.style?.removeLayer(oldLayer)
        }
        
        if let oldSource = mapView.style?.source(withIdentifier: sourceIdentifier) {
            mapView.style?.removeSource(oldSource)
        }
        
        let dbManager = LFCachedDatabaseManager.shared
        let cachedPoints = dbManager.getPointsIn(zoomLevel: level)
        
        guard cachedPoints.count > 0 else {
            return
        }
        
        var coordinates: [CLLocationCoordinate2D] = cachedPoints.map { (point) -> CLLocationCoordinate2D in
            return MKCoordinateForMapPoint(MKMapPointMake(Double(point.x), Double(point.y)))
        }
        let pointsCollection = MGLPointCollectionFeature(coordinates: &coordinates, count: UInt(coordinates.count))
        
        let source = MGLShapeSource(identifier: sourceIdentifier, features: [pointsCollection!], options: nil)
        mapView.style?.addSource(source)
        
        let layer = MGLCircleStyleLayer(identifier: layerIdentifier, source: source)
        layer.sourceLayerIdentifier = sourceIdentifier
        layer.circleColor = MGLStyleValue(rawValue: .green)
        layer.circleRadius = MGLStyleValue(rawValue: 2)
        layer.circleOpacity = MGLStyleValue(rawValue: 0.7)
        mapView.style?.addLayer(layer)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: basic configuration
    fileprivate func configureMap() {
        let styleURL = NSURL(string: "mapbox://styles/echx/cj1apel6y00ah2qmu2olw1zhl")! as URL
        mapView.styleURL = styleURL
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.delegate = self
    }
}

extension LFHistoryMapboxViewController: LFStoryboardBasedController {
    class func defaultControllerFromStoryboard() -> LFViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LFHistoryViewMapboxController") as! LFViewController
        
        return controller
    }
}
