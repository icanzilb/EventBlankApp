//
//  FontAwesome+UILabel.swift
//  Swift-Font-Awesome
//
//  Created by longhao on 15/7/7.
//  Copyright (c) 2015年 longhao. All rights reserved.
//

import UIKit

extension UILabel: FaProtocol {
    var fa: Fa? {
        get {
            if let txt = text {
                //only support FaTextAlignment.Left
                var indexTo = advance(txt.startIndex, 1)
                if let index =  find(FontContentArray, txt.substringToIndex(indexTo)) {
                    return Fa(rawValue: index)!
                }
            }
            return nil
        }
        
        set {
            if let value = newValue {
                FontAwesome.sharedManager.registerFont()
                let fontAwesome = UIFont(name: kFontAwesome, size: self.font.pointSize)
                font = fontAwesome!
                if let txt = text {
                    if let align = faTextAlignment {
                        switch align {
                        case .Left:
                            text = value.text! + txt
                            break
                        case .Right:
                            text = txt + value.text!
                            break
                        default:
                            text = value.text! + txt
                        }
                    }
                }else{
                    text = value.text!
                }
            }
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
