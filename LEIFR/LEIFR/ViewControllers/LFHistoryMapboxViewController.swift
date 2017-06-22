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
    
    enum LayerIndex {
        case low, mid, high
    }
    let layerIdentifiers = ["pathLayer-low", "pathLayer-mid", "pathLayer-high"]
    let sourceIdentifiers = ["pathSource-low", "pathSource-mid", "pathSource-high"]
    let layerColors: [UIColor] = [.green, .yellow, .red]
    var presentedLevel = 1
    var cachedLayers: [MGLCircleStyleLayer] = []
    var cachedSources: [MGLShapeSource] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        loadLayer(withLevel: presentedLevel)
    }
    
    func mapViewRegionIsChanging(_ mapView: MGLMapView) {
        let newLevel = Int(mapView.zoomLevel) + 4
        if newLevel != presentedLevel {
            presentedLevel = newLevel
            loadLayer(withLevel: presentedLevel)
        }
    }
    
    private func loadLayer(withLevel level: Int) {
        for layerIdentifier in layerIdentifiers {
            if let oldLayer = mapView.style?.layer(withIdentifier: layerIdentifier) {
                mapView.style?.removeLayer(oldLayer)
            }
        }
        
        for sourceIdentifier in sourceIdentifiers {
            if let oldSource = mapView.style?.source(withIdentifier: sourceIdentifier) {
                mapView.style?.removeSource(oldSource)
            }
        }
        
        let dbManager = LFCachedDatabaseManager.shared
        let cachedPoints = dbManager.getPointsIn(zoomLevel: level)
        
        guard cachedPoints.count > 0 else {
            return
        }
        
        // some nasty way to add different level of layers
        let cachedPointsLow = cachedPoints.filter { (point) -> Bool in
            return point.count < 5
        }
        
        let cachedPointsMid = cachedPoints.filter { (point) -> Bool in
            return point.count >= 5 && point.count < 20
        }
        
        let cachedPointsHigh = cachedPoints.filter { (point) -> Bool in
            return point.count > 20
        }
        
        addLayer(points: cachedPointsLow, index: .low)
        addLayer(points: cachedPointsMid, index: .mid)
        addLayer(points: cachedPointsHigh, index: .high)
    }
    
    
    fileprivate func addLayer(points: [LFCachedPoint], index: LayerIndex) {
        let i = index.hashValue
        var coordinates: [CLLocationCoordinate2D] = points.map { (point) -> CLLocationCoordinate2D in
            return MKCoordinateForMapPoint(MKMapPointMake(Double(point.x), Double(point.y)))
        }
        
        let pointsCollection = MGLPointCollectionFeature(coordinates: &coordinates, count: UInt(coordinates.count))
        
        let source = MGLShapeSource(identifier: sourceIdentifiers[i], features: [pointsCollection!], options: nil)
        mapView.style?.addSource(source)
        
        let layer = MGLCircleStyleLayer(identifier: layerIdentifiers[i], source: source)
        layer.sourceLayerIdentifier = sourceIdentifiers[i]
        layer.circleColor = MGLStyleValue(rawValue: layerColors[i])
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
    
    @IBAction override func toggleUserLocation(sender: UIButton) {
        if !isTrackingUserLocation {
            isTrackingUserLocation = true
        } else {
            sender.isSelected = !sender.isSelected
        }
    }
}

extension LFHistoryMapboxViewController: LFStoryboardBasedController {
    class func defaultControllerFromStoryboard() -> LFViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LFHistoryViewMapboxController") as! LFViewController
        
        return controller
    }
}
