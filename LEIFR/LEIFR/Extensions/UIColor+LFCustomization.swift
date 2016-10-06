//
//  UIColor+LFCustomization.swift
//  LEIFR
//
//  Created by Lei Mingyu on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

extension UIColor {
    class func eightBitColor(red: Float, green: Float, blue: Float, alpha: Float) -> UIColor {
        return self.init(colorLiteralRed: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}

