//
//  ReusableParts.swift
//  safety202102
//
//  Created by Chihiro Nishiwaki on 2021/03/08.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

extension CustomButton {

    //影付きのボタンの生成
    internal func commonInit(){
        self.layer.cornerRadius = 20
        self.layer.shadowOffset = CGSize(width: 1, height: 1 )
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 1.0

    }
    
}
    


