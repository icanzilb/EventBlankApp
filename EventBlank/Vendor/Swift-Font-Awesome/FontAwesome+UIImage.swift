//
//  FontAwesome+UIImage.swift
//  Swift-Font-Awesome
//
//  Created by longhao on 15/7/18.
//  Copyright (c) 2015年 longhao. All rights reserved.
//

import UIKit

extension UIImage {
    //https://github.com/melvitax/AFImageHelper/blob/master/AF%2BImage%2BHelper/AF%2BImage%2BExtension.swift
    convenience init?(faCircle: Fa, font: UIFont = FaType.LG.font, color: UIColor = UIColor.whiteColor(), circleFont: UIFont = FaType.X4.font,circleColor: UIColor = UIColor.blackColor(), backgroundColor: UIColor = UIColor.grayColor(), size:CGSize = CGSizeMake(64, 64), offset: CGPoint = CGPoint(x: 0, y: 8), circleOffset: CGPoint = CGPoint(x: 0, y: 0))
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        let attr = [NSFontAttributeName:font, NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName:style]
        
        let rect = CGRect(x: circleOffset.x, y: circleOffset.y, width: size.width, height: size.height)
        let attrCircle = [NSFontAttributeName:circleFont, NSForegroundColorAttributeName:circleColor, NSParagraphStyleAttributeName:style]
        Fa.Circle.text!.drawInRect(rect, withAttributes: attrCircle)
        
        let rectIn = CGRect(x: offset.x, y: offset.y, width: size.width, height: size.height)
        faCircle.text!.drawInRect(rectIn, withAttributes: attr)
        self.init(CGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage)
        UIGraphicsEndImageContext()
    }
    
    // MARK: Image with Text
    convenience init?(fa: Fa, font: UIFont = FaType.LG.font, color: UIColor = UIColor.whiteColor(), backgroundColor: UIColor = UIColor.grayColor(), size:CGSize = CGSizeMake(64, 64), offset: CGPoint = CGPoint(x: 0, y: 0))
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor)
        CGContextFillRect(context, CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        var style = NSMutableParagraphStyle()
        style.alignment = .Center
        let attr = [NSFontAttributeName:font, NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName:style]
        let rect = CGRect(x: offset.x, y: offset.y, width: size.width, height: size.height)
        fa.text!.drawInRect(rect, withAttributes: attr)
        self.init(CGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage)
        UIGraphicsEndImageContext()
    }
    
}
