//
//  MyView.swift
//  BuzzLabor
//
//  Created by Jay Balderas on 6/3/17.
//  Copyright © 2017 Jay Balderas. All rights reserved.
//

import UIKit

@IBDesignable
class MyView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
         UserStylingViewController.drawUserMain(frame: self.bounds, resizing: .aspectFill)
    }
    

}
