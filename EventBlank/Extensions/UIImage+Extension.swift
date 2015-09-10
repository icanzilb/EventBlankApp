//
//  UIImage+Extension.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/10/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

extension UIImage {
    
    func asyncToSize(size: CGSize, cornerRadius: CGFloat = 0.0, completion: ((UIImage?)->Void)? = nil) {

        var result: UIImage? = nil
        
        backgroundQueue({
            let rect = CGRect(origin: CGPoint.zeroPoint, size: size)

            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
            CGContextAddPath(UIGraphicsGetCurrentContext(), UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).CGPath)
            CGContextClip(UIGraphicsGetCurrentContext())
            
            self.drawInRect(rect)
            
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }, completion: {
            completion?(result)
        })
    }
}
