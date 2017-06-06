//
//  LFHistoryMapboxViewController.swift
//  LEIFR
//
//  Created by Lei Mingyu on 7/6/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import Mapbox

class LFHistoryMapboxViewController: LFHistoryViewController {
    @IBOutlet fileprivate weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMap()
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
    }
}

extension LFHistoryMapboxViewController: LFStoryboardBasedController {
    class func defaultControllerFromStoryboard() -> LFViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LFHistoryViewMapboxController") as! LFViewController
        
        return controller
    }
}
