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
    let button = UIButton.buttonWithType(.Custom) as! UIButton
    
    var tapHandler: (()->Void)?
    
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
    
    convenience init(text: String, buttonTitle: String, buttonTap: ()->Void) {
        self.init(text: text)
        
        button.setTitle(buttonTitle, forState: .Normal)
        let primaryColor = UIColor(hexString: (UIApplication.sharedApplication().delegate as! AppDelegate).event[Event.mainColor])
        button.backgroundColor = primaryColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.addTarget(self, action: "didTapButton:", forControlEvents: .TouchUpInside)
        
        addSubview(button)
        
        tapHandler = buttonTap
    }
    
    func didTapButton(sender: AnyObject) {
        tapHandler?()
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
        
        frame = CGRectInset(newSuperview!.bounds, 16, 0)
        label.frame = bounds

        let tabBarHeight = ((UIApplication.sharedApplication().windows.first! as! UIWindow).rootViewController as! UITabBarController).tabBar.frame.size.height
        
        button.sizeToFit()
        button.frame.size.width *= 1.2
        button.center = CGPoint(
            x: bounds.size.width/2,
            y: (bounds.size.height - button.bounds.size.height - tabBarHeight) * 0.9
        )
    }
    
    static func removeViewFrom(view: UIView) {
        for sv in view.subviews as! [UIView] {
            if let sv = sv as? MessageView {
                sv.removeFromSuperview()
            }
        }
    }
}
