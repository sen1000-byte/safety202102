//
//  ColorExtension.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/03.
//

import Foundation
import UIKit

extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    class func backGroundGreenColor() -> UIColor {
        let color = UIColor.init(red: 230 / 255, green: 241 / 255, blue: 220 / 255, alpha: 1)
        return color
    }
    
    class func lightPinkColor() -> UIColor {
        let color = UIColor.init(red: 255 / 255, green: 238 / 255, blue: 251 / 255, alpha: 1)
        return color
    }
    
    class func smileYellowColor() -> UIColor {
        let color = UIColor.init(red: 243 / 225, green: 225 / 225, blue: 127 / 225, alpha: 1)
        return color
    }
    
    
}
