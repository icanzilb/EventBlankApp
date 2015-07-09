//
//  MessageView.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/25/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class MessageView: UIView {
    
    var message = ""
    let label = UILabel()
    
    convenience init(text: String) {
        self.init()
        message = text
        
        label.text = text
        label.font = UIFont.systemFontOfSize(16.0)
        label.textColor = UIColor.darkGrayColor()
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.whiteColor()
        addSubview(label)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview == nil {
            return
        }
        
        for sv in newSuperview?.subviews as! [UIView] {
            if let sv = sv as? MessageView {
                sv.removeFromSuperview()
            }
        }
        
        frame = newSuperview!.bounds
        label.frame = bounds
    }
    
    static func removeViewFrom(view: UIView) {
        for sv in view.subviews as! [UIView] {
            if let sv = sv as? MessageView {
                sv.removeFromSuperview()
            }
        }
    }
}
