//
//  LFRecordButton.swift
//  LEIFR
//
//  Created by Lei Mingyu on 12/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

protocol LFRecordButtonDelegate {
    func button(_ button: LFRecordButton, isForceTouchedWithForce force: CGFloat)
}

class LFRecordButton: UIButton {
    var delegate: LFRecordButtonDelegate?
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        if traitCollection.forceTouchCapability == .available {
            self.delegate?.button(self, isForceTouchedWithForce: touch.force)
        }
    }
}
