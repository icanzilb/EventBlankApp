//
//  FontAwesome+UIButton.swift
//  Swift-Font-Awesome
//
//  Created by longhao on 15/7/8.
//  Copyright (c) 2015年 longhao. All rights reserved.
//

import UIKit

extension UIButton: FaProtocol {
    func fa(fa: Fa, forState state: UIControlState){
        FontAwesome.sharedManager.registerFont()
        let fontAwesome = UIFont(name: kFontAwesome, size: self.titleLabel!.font.pointSize)
        titleLabel!.font = fontAwesome!
        if let txt = titleLabel!.text {
            if let align = faTextAlignment {
                switch align {
                case .Left:
                    setTitle(fa.text! + txt, forState: state)
                    break
                case .Right:
                    setTitle(txt + fa.text!, forState: state)
                    break
                default:
                    setTitle(fa.text! + txt, forState: state)
                }
            }
        }else{
            setTitle(fa.text, forState: state)
        }
    }
    
    var faTextAlignment: FaTextAlignment? {
        get {
            if let _align = align {
                return _align
            }else {
                return FaTextAlignment.Left
            }
        }
        set {
            align = newValue
        }
    }
}
