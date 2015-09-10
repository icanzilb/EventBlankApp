//
//  UIImage+Extension.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/10/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

extension UIImage {
    
    func asyncToSize(newSize: CGSize, cornerRadius: CGFloat = 0.0, completion: ((UIImage?)->Void)? = nil) {

        var result: UIImage? = nil
        
        backgroundQueue({
            
            let aspectWidth = newSize.width / self.size.width
            let aspectHeight = newSize.height / self.size.height
            let aspectRatio = max(aspectWidth, aspectHeight)
            
            var rect = CGRect.zeroRect
            
            rect.size.width = self.size.width * aspectRatio
            rect.size.height = self.size.height * aspectRatio
            rect.origin.x = (newSize.width - rect.size.width) / 2.0
            rect.origin.y = (newSize.height - rect.size.height) / 2.0

            UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.mainScreen().scale)
            if cornerRadius > 0.0 {
                CGContextAddPath(UIGraphicsGetCurrentContext(), UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).CGPath)
                CGContextClip(UIGraphicsGetCurrentContext())
            }
            self.drawInRect(rect)
            
            result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }, completion: {
            completion?(result)
        })
    }
}