//
//  LFNavigationBar.swift
//  LEIFR
//
//  Created by Jinghan Wang on 30/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class LFNavigationBar: UIVisualEffectView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		let layer = self.layer
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowPath = UIBezierPath(rect: CGRect(x: -5, y: 0, width: self.bounds.width + 10, height: self.bounds.height)).cgPath
		layer.shadowOpacity = 0.10
		layer.shadowRadius = 3
	}

}
