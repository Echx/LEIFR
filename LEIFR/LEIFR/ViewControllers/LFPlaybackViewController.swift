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
    @IBOutlet weak var dateTimeView: UIView!
    @IBOutlet weak var dateTimeViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    fileprivate var paths: [LFPath]?
    fileprivate var animateAnnotation: MKPointAnnotation?
    fileprivate var pauseAnnotation: MKPointAnnotation?
    fileprivate var startDate: Date?
    fileprivate var animationFactor = 60.0
    fileprivate var playbackState: PlaybackState = .stop
    fileprivate var playingPathIndex = 0
    fileprivate var playingPointIndex = 0
    fileprivate var pausePathIndex = 0
    fileprivate var pausePointIndex = 0
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate var availableDates = [(Date, Date)]()
    fileprivate var animationTimers = [Timer]()
    fileprivate var annotationRemovalTimer: Timer?
    fileprivate var dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateTimeViewTopConstraint.constant = -self.dateTimeView.frame.size.height
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = TimeZone(abbreviation: "SGT")
        mapView.delegate = self
        animateAnnotation = MKPointAnnotation()
        loadDateData()
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
    
    fileprivate func loadDateData() {
        if availableDates.count == 0 {
            LFDatabaseManager.shared.getAllPaths {
                paths in
                
                for path in paths {
                    let startPoint = path.points().firstObject as! WKBPoint
                    let endPoint = path.points().lastObject as! WKBPoint
                    var startDate = startPoint.time
                    var endDate = endPoint.time
                    var startComponent = self.gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate)
                    var endComponent = self.gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endDate)
                    startComponent.hour = 0
                    startComponent.minute = 0
                    startComponent.second = 0
                    endComponent.hour = 23
                    endComponent.minute = 59
                    endComponent.second = 59
                    startDate = self.gregorian.date(from: startComponent)!
                    endDate = self.gregorian.date(from: endComponent)!
                    
                    self.availableDates.append((startDate, endDate))
                }
                
                self.mergeDates()
            }
        }
    }
    
    fileprivate func mergeDates() {
        guard availableDates.count > 0 else {
            return
        }
        
        availableDates.sort {
            $0.0 < $1.0
        }
        
        var mergedDates = [(Date, Date)]()
        var currentDates = availableDates[0]
        for (startDate, endDate) in availableDates {
            // check overlap
            if (startDate < currentDates.0 && endDate < currentDates.0) || (startDate > currentDates.1 && endDate > currentDates.1) {
                mergedDates.append(currentDates)
                currentDates = (startDate, endDate)
            } else {
                currentDates = (min(startDate, currentDates.0), max(endDate, currentDates.1))
            }
        }
        mergedDates.append(currentDates)
        availableDates = mergedDates
    }
    
    fileprivate func playAnimation() {
        playingPathIndex = max(playingPathIndex, pausePathIndex)
        
        guard playingPathIndex < (self.paths?.count)! else {
            self.mapView.removeAnnotation(self.animateAnnotation!)
            
            self.playButton.isSelected = false
            self.playbackState = .play
            self.stopButton.isHidden = true
            
            return
        }
        
        let path = self.paths?[playingPathIndex]
        playingPathIndex += 1
        playingPointIndex = pausePointIndex
        pausePathIndex = 0
        
        var delay = 0.0
        let points = (path?.points())!
        
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
        
        DispatchQueue(label:
            "background").asyncAfter(deadline: .now()) {
            var previousM: Double?
            var animationTime = 0.1
            for k in self.pausePointIndex..<points.count {
                self.pausePointIndex = 0
                let point = points[k]
                let wkbPoint = point as! WKBPoint
                if previousM != nil {
                    animationTime = (Double(wkbPoint.m) - previousM!) / self.animationFactor
                }
                previousM = wkbPoint.m as Double?
                DispatchQueue.main.async {
                    let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                        _ in
                        
                        self.playingPointIndex += 1
                        
                        UIView.animate(withDuration: animationTime, animations: {
                            self.animateAnnotation?.coordinate = wkbPoint.coordinate()
                            self.dateTimeLabel.text = self.dateFormatter.string(from: wkbPoint.time)
//                            self.mapView.centerCoordinate = wkbPoint.coordinate()
                        })
                    }
                    self.animationTimers.append(timer)
                    delay += animationTime
                }
            }
            
            delay += 0.1
            DispatchQueue.main.async {
                
                self.annotationRemovalTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                    _ in
                    
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
        calenderViewController.availableDates = availableDates
        
        self.present(calenderViewController, animated: true, completion: nil)
    }
    
    @IBAction func togglePlay() {
        switch playbackState {
        case .pause:
            fallthrough
            
        case .stop:
            // change state
            playButton.isSelected = true
            playbackState = .play
            // show stop button
            stopButton.isHidden = false
            // show date time view
            UIView.animate(withDuration: 0.5, animations: {
                self.dateTimeViewTopConstraint.constant = 0
            })
            
            if pauseAnnotation != nil {
                mapView.removeAnnotation(pauseAnnotation!)
            }
            mapView.addAnnotation(animateAnnotation!)
            playAnimation()
            LFHoverTabBaseController.defaultInstance.collapseTabView()
            break
            
        case .play:
            // change state
            playButton.isSelected = false
            playbackState = .pause
            
            for timer in animationTimers {
                timer.invalidate()
            }
            
            animationTimers = [Timer]()
            
            if annotationRemovalTimer != nil {
                annotationRemovalTimer?.invalidate()
                annotationRemovalTimer = nil
            }
            
            pausePathIndex = playingPathIndex - 1
            playingPathIndex = 0
            pausePointIndex = playingPointIndex
            pauseAnnotation = MKPointAnnotation()
            pauseAnnotation?.coordinate = (animateAnnotation?.coordinate)!
            mapView.addAnnotation(pauseAnnotation!)
            if animateAnnotation != nil {
                mapView.removeAnnotation(animateAnnotation!)
            }
            
            break
        }
        
    }
    
    @IBAction func stopPlay() {
        playButton.isSelected = false
        playbackState = .stop
        
        stopButton.isHidden = true
        
        // hide date time view
        UIView.animate(withDuration: 0.5, animations: {
            self.dateTimeViewTopConstraint.constant = -self.dateTimeView.frame.size.height
        })
        
        for timer in animationTimers {
            timer.invalidate()
        }
        
        animationTimers = [Timer]()
        
        if annotationRemovalTimer != nil {
            annotationRemovalTimer?.invalidate()
            annotationRemovalTimer = nil
        }
        
        if pauseAnnotation != nil {
            mapView.removeAnnotation(pauseAnnotation!)
        }
        
        if animateAnnotation != nil {
            mapView.removeAnnotation(animateAnnotation!)
        }
        
        playingPathIndex = 0
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
