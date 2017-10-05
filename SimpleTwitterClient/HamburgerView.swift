//
//  HamburgerView.swift
//  SimpleTwitterClient
//
//  Created by Diana Fisher on 10/4/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

class HamburgerView: UIView {

    let imageView: UIImageView! = UIImageView(image: UIImage(named: "burger"))
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    fileprivate func setup()
    {
        imageView.contentMode = UIViewContentMode.center
        
        addSubview(imageView)
    }
    
    func rotate(_ fraction: CGFloat) {
        let angle = Double(fraction) * (Double.pi * 2)
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(angle))
    }
}
