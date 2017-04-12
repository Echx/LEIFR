//
//  LFPlaybackViewController.swift
//  LEIFR
//
//  Created by Jinghan Wang on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var playbackProgressView: UIProgressView!
    
    fileprivate var playbackState: PlaybackState = .stop
    fileprivate var startDate: Date?
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate var availableDates = [(Date, Date)]()
    fileprivate let pathsPlayingManager = LFPathsPlayingManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playbackProgressView.progress = 0
        dateTimeViewTopConstraint.constant = -self.dateTimeView.frame.size.height
        mapView.delegate = self
        pathsPlayingManager.delegate = self
        pathsPlayingManager.mapView = mapView
        pathsPlayingManager.dateTimeLabel = dateTimeLabel
        pathsPlayingManager.playbackProgressView = playbackProgressView
        loadDateData()
    }
    
    fileprivate func loadMapData() {
        if startDate != nil {
            LFDatabaseManager.shared.getPathsFromTime(startDate!) {
                paths in
                
                if paths.count == 0 {
                    self.startDate = nil
                    LFHoverTabViewController.defaultInstance.reloadControlView()
                } else {
                    let sortedPath = paths.sorted(by: {
                        (pathA, pathB) -> Bool in
                        return pathA.startTime! < pathB.startTime!
                    })
                    self.pathsPlayingManager.clearAllPaths()
                    self.pathsPlayingManager.addPaths(sortedPath)
                }
            }
        }
    }
    
    fileprivate func loadDateData() {
        if availableDates.count == 0 {
            LFDatabaseManager.shared.getAllPaths {
                paths in

                for path in paths {
                    var startDate = path.startTime!
                    var endDate = path.endTime!
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
        if pathsPlayingManager.canPlay() {
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
            
            self.pathsPlayingManager.playAnimation()
            LFHoverTabBaseController.defaultInstance.collapseTabView()
            break
            
        case .play:
            // change state
            playButton.isSelected = false
            playbackState = .pause
            
            self.pathsPlayingManager.killTimers()
            self.pathsPlayingManager.pauseAnimation()
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
            
            self.view.layoutIfNeeded()
        })
        
        self.pathsPlayingManager.stopAnimation()
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            renderer.lineWidth = 4.0
            
            return renderer
        } else {
            return MKOverlayRenderer()
        }
    }
}

extension LFPlaybackViewController: LFPlaybackCalendarDelagate {
    func dateDidSelect(date: Date) {
        startDate = date
        LFHoverTabViewController.defaultInstance.reloadControlView()
        self.loadMapData()
    }
}


extension LFPlaybackViewController: LFPathsPlayingManagerDelegate {
    func didFinishAnimations() {
        self.playButton?.isSelected = false
        self.playbackState = .stop
        self.stopButton?.isHidden = true
    }
}
