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
    
    enum LayerIndex: Int {
        case low = 0
        case mid, high
    }
    let layerIdentifiers = ["pathLayer-low", "pathLayer-mid", "pathLayer-high"]
    let sourceIdentifiers = ["pathSource-low", "pathSource-mid", "pathSource-high"]
    let layerColors: [UIColor] = [.green, .yellow, .red]
    var presentedLevel = 1
    var cachedLevel = 11
    var cachedLayers: [MGLCircleStyleLayer] = []
    var cachedSources: [MGLShapeSource] = []
    var cachedPointLayers: [[LFCachedPoint]] = []
    var cachingLock = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preloadPoints()
        
        LFTrackTabViewController.defaultInstance = LFTrackTabViewController.controllerFromStoryboard() as! LFTrackTabViewController
    
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
    
//    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//        let newLevel = Int(mapView.zoomLevel) + 4
//        if newLevel != presentedLevel {
//            presentedLevel = newLevel
//            loadLayer(withLevel: presentedLevel)
//        }
//    }
    
    private func preloadPoints() {
        cachePoints(to: cachedLevel)
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
        
        var cachedPoints: [LFCachedPoint] = []
        if level < cachedPointLayers.count {
            cachedPoints = cachedPointLayers[level]
        } else {
//            let bounds = mapView.visibleCoordinateBounds
//            cachedPoints = loadPoints(for: bounds, zoomLevel: level)
        }
        
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
    
    private func cachePoints(to level: Int) {
        if !cachingLock {
            cachingLock = true
            let currentLevel = cachedPointLayers.count
            while cachedPointLayers.count <= level {
                cachedPointLayers.append([])
            }
            
            for cachingLevel in currentLevel...level {
                let dbManager = LFCachedDatabaseManager.shared
                cachedPointLayers[cachingLevel] = dbManager.getPointsIn(zoomLevel: cachingLevel)
            }
            cachingLock = false
        }
        
    }
    
    private func loadPoints(for bounds: MGLCoordinateBounds, zoomLevel: Int) -> [LFCachedPoint] {
        let dbManager = LFCachedDatabaseManager.shared
        let points = dbManager.getPointsIn(bounds, zoomLevel: zoomLevel)
        
        if points.count == 0 {
            print("oops")
            
            dbManager.reconstructDatabaseFor(bounds: bounds, zoomLevel: zoomLevel)
        }
        return points
    }
    
    private func addLayer(points: [LFCachedPoint], index: LayerIndex) {
        let i = index.rawValue
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
        mapView.showsUserLocation = !mapView.showsUserLocation
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
