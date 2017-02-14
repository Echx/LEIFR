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
    
    @IBOutlet weak var mapView: MKMapView!
    
    fileprivate var paths: [LFPath]?
    fileprivate var animateAnnotation: MKPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.loadMapData()
        self.animateAnnotation = MKPointAnnotation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadMapData() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        LFDatabaseManager.shared.getPathsFromTime(formatter.date(from: "2016/06/01")!) { paths in
            
            print(paths.count) // 341
            let start = formatter.date(from: "2016/06/01")!
            let end = formatter.date(from: "2016/12/09")!
            
            self.paths = paths.filter {
                $0.isOverlappedWith(startDate: start, endDate: end)
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
        let view = UIView.view(fromNib: "LFPlaybackControlView", owner: self)
        return view
    }
    
    @IBAction func showCalendarPicker() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let calenderViewController = storyboard.instantiateViewController(withIdentifier: "LFPlaybackCalendarViewController") as! LFPlaybackCalendarViewController
        calenderViewController.modalTransitionStyle = .crossDissolve
        
        self.present(calenderViewController, animated: true, completion: nil)

    }
    
    @IBAction func playAnimation() {
        let path = self.paths?[0]
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
        
        DispatchQueue(label: "background").asyncAfter(deadline: .now() + 3) {
            print(Date())
            let animationOrigin = DispatchTime.now()
            for point in points {
                let wkbPoint = point as! WKBPoint
                print(delay)
                DispatchQueue.main.asyncAfter(deadline: animationOrigin + delay, execute: {
                    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                        self.animateAnnotation?.coordinate = wkbPoint.coordinate()
                    }, completion: nil)
                })
                print("haha")
                delay += 1
            }
            
            print(Date())
            
            delay += 1
            
            Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
                _ in
                
                self.mapView.removeAnnotation(self.animateAnnotation!)
            }
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
