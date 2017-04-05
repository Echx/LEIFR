//
//  LFPathPlayingManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 20/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFPathPlayingManager: NSObject {
    
    fileprivate var mapView: MKMapView?
    fileprivate var animateAnnotation: MKPointAnnotation?
    fileprivate var pauseAnnotation: MKPointAnnotation?
    fileprivate var playingPathIndex = 0
    fileprivate var playingPointIndex = 0
    fileprivate var pausePathIndex = 0
    fileprivate var pausePointIndex = 0
    fileprivate var pathPolyline: MKPolyline?
    fileprivate var animationTimers = [Timer]()
    fileprivate var annotationRemovalTimer: Timer?
    fileprivate var animationFactor = 60.0
    fileprivate var dateFormatter = DateFormatter()
    var paths = [LFPath]()
    var delegate: LFPathPlayingManagerDelegate?
    
    init(_ mapView: MKMapView?, paths: [LFPath]) {
        super.init()
        
        self.mapView = mapView
        self.paths = paths
        self.animateAnnotation = MKPointAnnotation()
        self.pauseAnnotation = MKPointAnnotation()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = TimeZone(abbreviation: "SGT")
    }
    
    func prepareAnnotation() {
        self.mapView?.addAnnotation(self.animateAnnotation!)
        if pauseAnnotation != nil {
            mapView?.removeAnnotation(pauseAnnotation!)
        }
    }
    
    func killTimers() {
        for timer in animationTimers {
            timer.invalidate()
        }
        
        animationTimers = [Timer]()
        
        if annotationRemovalTimer != nil {
            annotationRemovalTimer?.invalidate()
            annotationRemovalTimer = nil
        }
    }
    
    func stopAnimation() {
        for timer in animationTimers {
            timer.invalidate()
        }
        
        animationTimers = [Timer]()
        
        if annotationRemovalTimer != nil {
            annotationRemovalTimer?.invalidate()
            annotationRemovalTimer = nil
        }
        
        if pauseAnnotation != nil {
            mapView?.removeAnnotation(pauseAnnotation!)
        }
        
        if animateAnnotation != nil {
            mapView?.removeAnnotation(animateAnnotation!)
        }
        
        if pathPolyline != nil {
            mapView?.remove(pathPolyline!)
        }
        
        pausePointIndex = 0
        pausePathIndex = 0
        playingPointIndex = 0
        playingPathIndex = 0
    }
    
    func pauseAnimation() {
        pausePathIndex = playingPathIndex - 1
        playingPathIndex = 0
        pausePointIndex = playingPointIndex
        pauseAnnotation = MKPointAnnotation()
        pauseAnnotation?.coordinate = (animateAnnotation?.coordinate)!
        mapView?.addAnnotation(pauseAnnotation!)
        if animateAnnotation != nil {
            mapView?.removeAnnotation(animateAnnotation!)
        }
    }
    
    func playAnimation() {
        playingPathIndex = max(playingPathIndex, pausePathIndex)
        
        guard playingPathIndex < (self.paths.count) else {
            self.mapView?.removeAnnotation(self.animateAnnotation!)
            self.delegate?.didFinishAnimation()
            self.playingPathIndex = 0
            self.playingPointIndex = 0
            
            return
        }
        
        let path = self.paths[playingPathIndex]
        playingPathIndex += 1
        playingPointIndex = pausePointIndex
        pausePathIndex = 0
        
        var delay = 0.0
        let points = path.points
       
        if self.pathPolyline != nil {
            self.mapView?.remove(self.pathPolyline!)
        }
        self.pathPolyline = MKPolyline(coordinates: path.coordinates(), count: points.count)
        self.mapView?.add(self.pathPolyline!, level: .aboveRoads)
        
        var zoomRect = MKMapRectNull
        DispatchQueue(label: "background").async {
            for point in points {
                let fakeAnnotationPoint = MKMapPointForCoordinate(point.coordinate)
                let fakePointRect = MKMapRectMake(fakeAnnotationPoint.x, fakeAnnotationPoint.y, 0, 0)
                if MKMapRectIsNull(zoomRect) {
                    zoomRect = fakePointRect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, fakePointRect)
                }
            }
            
            DispatchQueue.main.async {
                self.mapView?.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(10, 10, 10, 10), animated: true)
            }
        }
        
        DispatchQueue(label: "background").asyncAfter(deadline: .now()) {
            var previousM: Double?
            var animationTime = 0.1
            if self.pausePointIndex >= points.count {
                self.pausePointIndex = 0
            }
            for k in self.pausePointIndex..<points.count {
                self.pausePointIndex = 0
                let point = points[k]
                if previousM != nil {
                    animationTime = (point.m - previousM!) / self.animationFactor
                }
                previousM = point.m
                DispatchQueue.main.async {
                    let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                        _ in
                        
                        self.playingPointIndex += 1
                        self.delegate?.updateTo(progress: Float(self.playingPointIndex) / Float(points.count), timeString: self.dateFormatter.string(from: point.time))
                        
                        UIView.animate(withDuration: animationTime, animations: {
                            self.animateAnnotation?.coordinate = point.coordinate
                        })
                        
                    }
                    self.animationTimers.append(timer)
                    delay += animationTime
                }
            }
            
            delay += 1
            DispatchQueue.main.async {
                
                self.annotationRemovalTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                    _ in
                    
                    self.playAnimation()
                }
            }
        }
    }
}

protocol LFPathPlayingManagerDelegate {
    func didFinishAnimation()
    
    func updateTo(progress: Float, timeString: String)
}
