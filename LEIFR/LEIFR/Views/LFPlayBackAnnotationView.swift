//
//  LFPlayBackAnnotationView.swift
//  LEIFR
//
//  Created by Lei Mingyu on 1/2/17.
//  Copyright © 2017 Echx. All rights reserved.
//

import UIKit
import MapKit

class LFPlaybackAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        self.backgroundColor = .black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var identifier: String {
        get {
            return String(describing: self)
        }
    }
}
