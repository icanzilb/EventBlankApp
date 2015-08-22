//
//  UIView+Extensions.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/22/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

extension UIView {
    
    func animateSelect(scale: CGFloat = 0.8, completion: (()->Void)?) {
        transform = CGAffineTransformMakeScale(scale, scale)
        UIView.animateWithDuration(0.33, delay: 0.01, usingSpringWithDamping: 0.2, initialSpringVelocity: 100.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.transform = CGAffineTransformIdentity
        }, completion: {_ in
            if let completion = completion {
                completion()
            }
        })
    }
    
}