//
//  UIKitExtension.swift
//  LEIFR
//
//  Created by Lei Mingyu on 7/10/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

extension UIColor {
	static let wetasphalt = UIColor(red: 51/255.0, green: 73/255.0, blue: 95/255.0, alpha: 1)
    class func eightBitColor(red: Float, green: Float, blue: Float, alpha: Float) -> UIColor {
        return self.init(colorLiteralRed: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}

extension UIView {
	class func view(fromNib nibName: String, owner: Any?) -> UIView? {
		return Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)![0] as? UIView
	}
}
