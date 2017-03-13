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
	
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
		let a, r, g, b: UInt32
		switch hex.characters.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
}

extension UIView {
	class func view(fromNib nibName: String, owner: Any?) -> UIView? {
		return Bundle.main.loadNibNamed(nibName, owner: owner, options: nil)![0] as? UIView
	}
}
