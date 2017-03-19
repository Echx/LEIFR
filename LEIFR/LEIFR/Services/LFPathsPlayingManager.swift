//
//  LFPathsPlayingManager.swift
//  LEIFR
//
//  Created by Lei Mingyu on 20/3/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit

class LFPathsPlayingManager: NSObject {
    
    static var shared = LFPathsPlayingManager()
    var delegate: LFPathsPlayingManagerDelegate?
    
    var mapView: MKMapView?
    fileprivate var paths = [[LFPath]]()
    fileprivate var pathManagers = [LFPathPlayingManager]()
    
    func clearAllPaths() {
        self.paths = [[LFPath]]()
        self.pathManagers = [LFPathPlayingManager]()
    }
    
    func addPaths(_ paths: [LFPath]) {
        self.paths.append(paths)
        let manager = LFPathPlayingManager(mapView, paths: paths)
        manager.delegate = self
        self.pathManagers.append(manager)
    }
    
    func playAnimation() {
        for manager in self.pathManagers {
            manager.prepareAnnotation()
            manager.playAnimation()
        }
    }
    
    func pauseAnimation() {
        for manager in self.pathManagers {
            manager.pauseAnimation()
        }
    }
    
    func stopAnimation() {
        for manager in self.pathManagers {
            manager.stopAnimation()
        }
    }
}

extension LFPathsPlayingManager: LFPathPlayingManagerDelegate {
    func didFinishAnimation() {
        self.delegate.didFinishAnimations()
    }
}

protocol LFPathsPlayingManagerDelegate {
    func didFinishAnimations()
}
