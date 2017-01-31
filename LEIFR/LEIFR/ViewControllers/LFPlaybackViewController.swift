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
        self.loadMapData()
        self.animateAnnotation = MKPointAnnotation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadMapData() {
        LFDatabaseManager.shared.getAllPaths { paths in
            
            
            print(paths.count) // 336
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
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
    
    @IBAction func playAnimation() {
        let path = self.paths?[0]
        let points = (path?.points())!
        let wkbPoint = points[0] as! WKBPoint
        var delay = 0.0
        
        self.animateAnnotation?.coordinate = CLLocationCoordinate2D(latitude: wkbPoint.latitude, longitude: wkbPoint.longitude)
        self.mapView.addAnnotation(self.animateAnnotation!)
        
        for point in points {
            let wkbPoint = point as! WKBPoint
            UIView.animate(withDuration: 0.01, delay: delay, options: .curveEaseInOut, animations: {
                self.animateAnnotation?.coordinate = CLLocationCoordinate2D(latitude: wkbPoint.latitude, longitude: wkbPoint.longitude)
            }, completion: nil)
            
            delay += 0.01
        }
        
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) {
            _ in
            
            self.mapView.removeAnnotation(self.animateAnnotation!)
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
