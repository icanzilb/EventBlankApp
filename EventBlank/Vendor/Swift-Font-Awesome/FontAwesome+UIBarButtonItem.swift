//
//  FontAwesome+UIBarButtonItem.swift
//  Swift-Font-Awesome
//
//  Created by longhao on 15/7/8.
//  Copyright (c) 2015年 longhao. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    var fa: Fa? {
        get {
            if let txt = self.title {
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
                let fontAwesome = FaType.LG.font
                setTitleTextAttributes([NSFontAttributeName: fontAwesome], forState: .Normal)
                if let txt = self.title {
                    if let align = faTextAlignment {
                        switch align {
                        case .Left:
                            self.title = value.text! + txt
                            break
                        case .Right:
                            self.title = txt + value.text!
                            break
                        default:
                            self.title = value.text! + txt
                        }
                    }
                }else{
                    self.title = value.text!
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
