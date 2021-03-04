//
//  Designable.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/03.
//

import Foundation
import UIKit

@IBDesignable
class DesignableView: UIView {
}

@IBDesignable
class GradationButton: UIButton {
    
    //初期値の値を透明にしたい
    @IBInspectable var Color1: UIColor = UIColor.orange
    @IBInspectable var Color2: UIColor = UIColor.red

    @IBInspectable var Point1: CGPoint = CGPoint.init(x: 0.5, y: 0)
    @IBInspectable var Point2: CGPoint = CGPoint.init(x: 0.5, y: 1)
    
    @IBInspectable var number: Int = 0

    // 実際の描画
    override func draw(_ rect: CGRect) {
        // グラデーションレイヤーを用意
        let gradientLayer = CAGradientLayer()
        // gradientLayerのサイズを指定
        gradientLayer.frame = self.bounds

        // グラデーションさせる色の指定
        let color1 = Color1.cgColor
        let color2 = Color2.cgColor

        // CAGradientLayerに色を設定（ここでたくさん色を指定することも可能？）
        gradientLayer.colors = [color1, color2]

        // グラデーションの開始点、終了点を設定（0~1）
        gradientLayer.startPoint = Point1
        gradientLayer.endPoint = Point2

        // ViewControllerの親Viewレイヤーにレイヤーを挿入する
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

@IBDesignable
class GradationLabel: UILabel {
    
    //初期値の値を透明にしたい
    @IBInspectable var Color1: UIColor = UIColor.orange
    @IBInspectable var Color2: UIColor = UIColor.red

    @IBInspectable var Point1: CGPoint = CGPoint.init(x: 0.5, y: 0)
    @IBInspectable var Point2: CGPoint = CGPoint.init(x: 0.5, y: 1)
    
    @IBInspectable var number: Int = 0

    // 実際の描画
    override func draw(_ rect: CGRect) {
        // グラデーションレイヤーを用意
        let gradientLayer = CAGradientLayer()
        // gradientLayerのサイズを指定
        gradientLayer.frame = self.bounds

        // グラデーションさせる色の指定
        let color1 = Color1.cgColor
        let color2 = Color2.cgColor

        // CAGradientLayerに色を設定（ここでたくさん色を指定することも可能？）
        gradientLayer.colors = [color1, color2]

        // グラデーションの開始点、終了点を設定（0~1）
        gradientLayer.startPoint = Point1
        gradientLayer.endPoint = Point2

        // ViewControllerの親Viewレイヤーにレイヤーを挿入する
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

//拡張する
extension UIView{
    @IBInspectable
    var cornerRadius: CGFloat{
        get{
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set{
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get{
            if let color = layer.borderColor{
                return UIColor(cgColor: color)
            }
            return nil
        }
        set{
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    

}


