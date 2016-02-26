//
//  MessageView.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/25/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class MessageView: UIView {
    
    // MARK: input
    var message = ""
    
    let label = UILabel()
    let button = UIButton(type: .Custom)
    
    // MARK: output
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
        //TODO: let primaryColor = UIColor(hexString: (UIApplication.sharedApplication().delegate as! AppDelegate).event[Event.mainColor])
        //button.backgroundColor = primaryColor
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
        guard let newSuperview = newSuperview else {
            return
        }
        
        for sv in newSuperview.subviews {
            if let sv = sv as? MessageView {
                sv.removeFromSuperview()
            }
        }
        
        frame = newSuperview.bounds
        label.frame = bounds

        let tabBarHeight = ((UIApplication.sharedApplication().windows.first!).rootViewController as! UITabBarController).tabBar.frame.size.height
        
        button.sizeToFit()
        button.frame.size.width *= 1.2
        button.center = CGPoint(
            x: bounds.size.width/2,
            y: (bounds.size.height - button.bounds.size.height - tabBarHeight) * 0.9
        )
    }
    
    static func removeViewFrom(view: UIView) {
        for sv in view.subviews {
            if let sv = sv as? MessageView {
                sv.removeFromSuperview()
            }
        }
    }
    
    static func toggle(superview: UIView, visible: Bool, text: String) {
        if visible {
            superview.addSubview(MessageView(text: text))
        } else {
            MessageView.removeViewFrom(superview)
        }
    }
}
