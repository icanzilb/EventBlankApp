//
//  FontAwesome+UIFont.swift
//  Swift-Font-Awesome
//
//  Created by longhao on 15/7/20.
//  Copyright (c) 2015年 longhao. All rights reserved.
//

import UIKit

extension UIFont {
    func fa(#size: CGFloat) -> UIFont {
        FontAwesome.sharedManager.registerFont()
        if let font = UIFont(name: kFontAwesome, size: size) {
            return font
        }
        return UIFont.systemFontOfSize(size)
    }
}
