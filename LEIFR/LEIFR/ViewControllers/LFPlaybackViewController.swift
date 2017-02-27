//
//  LFPlaybackViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import wkb_ios

class LFPlaybackViewController: LFViewController {
    
    enum PlaybackState {
        case stop, pause, play
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    fileprivate var paths: [LFPath]?
    fileprivate var animateAnnotation: MKPointAnnotation?
    fileprivate var startDate: Date?
    fileprivate var animationFactor = 60.0
    fileprivate var playbackState: PlaybackState = .stop
    fileprivate var playingIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.animateAnnotation = MKPointAnnotation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadMapData() {
        if startDate != nil {
            LFDatabaseManager.shared.getPathsFromTime(startDate!) {
                paths in
                
                if paths.count == 0 {
                    self.startDate = nil
                    LFHoverTabViewController.defaultInstance.reloadControlView()
                } else {
                    self.paths = paths
                }
            }
        }
    }
    
    fileprivate func playAnimation() {
        guard playingIndex < (self.paths?.count)!
            else {
                self.playButton.isSelected = false
                self.playbackState = .play
                self.stopButton.isHidden = true
                
                return
        }
        
        let path = self.paths?[playingIndex]
        playingIndex += 1
        let points = (path?.points())!
        let wkbPoint = points[0] as! WKBPoint
        var delay = 0.0
        
        self.animateAnnotation?.coordinate = wkbPoint.coordinate()
        self.mapView.addAnnotation(self.animateAnnotation!)
        
        var zoomRect = MKMapRectNull
        DispatchQueue(label: "background").async {
            for point in points {
                let wkbPoint = point as! WKBPoint
                let fakeAnnotationPoint = MKMapPointForCoordinate(wkbPoint.coordinate())
                let fakePointRect = MKMapRectMake(fakeAnnotationPoint.x, fakeAnnotationPoint.y, 0, 0)
                if MKMapRectIsNull(zoomRect) {
                    zoomRect = fakePointRect
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, fakePointRect)
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(10, 10, 10, 10), animated: true)
            }
        }
        
        DispatchQueue(label: "background").asyncAfter(deadline: .now() + 1) {
            var previousM: Double?
            var animationTime = 0.1
            for point in points {
                let wkbPoint = point as! WKBPoint
                if previousM != nil {
                    animationTime = (Double(wkbPoint.m) - previousM!) / self.animationFactor
                }
                previousM = wkbPoint.m as Double?
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                        _ in
                        
                        UIView.animate(withDuration: animationTime, animations: {
                            self.animateAnnotation?.coordinate = wkbPoint.coordinate()
                            //                            self.mapView.centerCoordinate = wkbPoint.coordinate()
                        })
                    }
                    delay += animationTime
                }
            }
            
            delay += 0.1
            DispatchQueue.main.async {
                
                Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                    _ in
                    
                    self.mapView.removeAnnotation(self.animateAnnotation!)
                    self.playAnimation()
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LFPlaybackViewController {
    override func controlViewForTab() -> UIView? {
        var view: UIView?
        if startDate != nil {
            view = UIView.view(fromNib: "LFPlaybackControlView", owner: self)
        } else {
            view = UIView.view(fromNib: "LFPlaybackCalendarView", owner: self)
        }
        return view
    }
    
    @IBAction func showCalendarPicker() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let calenderViewController = storyboard.instantiateViewController(withIdentifier: "LFPlaybackCalendarViewController") as! LFPlaybackCalendarViewController
        calenderViewController.modalTransitionStyle = .crossDissolve
        calenderViewController.delegate = self
        
        self.present(calenderViewController, animated: true, completion: nil)
    }
    
    @IBAction func togglePlay() {
        switch playbackState {
        case .stop:
            // change state
            playButton.isSelected = true
            playbackState = .play
            // show stop button
            stopButton.isHidden = false
            
            playAnimation()
            break
            
        case .play:
            // change state
            playButton.isSelected = false
            playbackState = .pause
            
            break
            
        case.pause:
            // change state
            playButton.isSelected = true
            playbackState = .play
            
            break
        }
        
    }
}

extension LFPlaybackViewController: LFStoryboardBasedController {
	class func defaultControllerFromStoryboard() -> LFViewController {
		let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "LFPlaybackViewController") as! LFViewController
		
		return controller
	}
}

extension LFPlaybackViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: LFPlaybackAnnotationView.identifier)
        
        if annotationView == nil {
            annotationView = LFPlaybackAnnotationView(annotation: annotation, reuseIdentifier: LFPlaybackAnnotationView.identifier)
        }
        
        return annotationView
    }
}

extension LFPlaybackViewController: LFPlaybackCalendarDelagate {
    func dateDidSelect(date: Date) {
        startDate = date
        LFHoverTabViewController.defaultInstance.reloadControlView()
        self.loadMapData()
    }
}
