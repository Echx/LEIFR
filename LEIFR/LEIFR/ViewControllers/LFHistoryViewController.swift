//
//  LFHistoryViewController.swift
//  LEIFR
//
//  Created by Lei Mingyu on 20/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFHistoryViewController: LFViewController {
    @IBOutlet fileprivate weak var mapView: MKMapView!
    
    @IBOutlet weak var recordButton: LFRecordButton!
    @IBOutlet weak var recordButtonContent: UIView!
    
    fileprivate var tileOverlay: MKTileOverlay?

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
        mapView.delegate = self
    }
}


extension LFHistoryViewController {
    override func controlViewForTab() -> UIView? {
        let view = Bundle.main.loadNibNamed("LFHistoryControlView", owner: self, options: nil)![0] as? UIView
        configureControlView()
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

extension LFHistoryViewController: LFStoryboardBasedController {
    class func defaultControllerFromStoryboard() -> LFViewController {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LFHistoryViewController") as! LFViewController
        
        return controller
    }
}

extension LFHistoryViewController: LFRecordButtonDelegate {
    func button(_ button: LFRecordButton, isForceTouchedWithForce force: CGFloat) {
        print(force)
        // TODO animation
    }
}

extension LFHistoryViewController: MKMapViewDelegate {

}

