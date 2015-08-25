//
//  FollowTwitterButton.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/23/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

enum FollowTwitterButtonState {
    case Checking, Follow, SendingRequest, Following
}

class FollowTwitterButton: UIButton {

    var followState: FollowTwitterButtonState = .Checking {
        didSet {
            mainQueue { self.refreshUI() }
        }
    }
    var username: String!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if superview == nil {
            return
        }
        
        layer.cornerRadius = 5.0
        backgroundColor = UIColor.whiteColor()
        layer.borderWidth = 1.0
        
        refreshUI()
    }
    
    func refreshUI() {
        layer.borderColor = colorForFollowState(followState).CGColor
        setTitle(titleForFollowState(followState), forState: .Normal)
        setTitleColor(colorForFollowState(followState), forState: .Normal)
    }
    
    func colorForFollowState(state: FollowTwitterButtonState) -> UIColor {
        switch state {
            case .Checking: return UIColor.orangeColor()
            case .Follow: return UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
            case .SendingRequest: return UIColor.darkGrayColor()
            case .Following: return UIColor.blueColor()
        }
    }
    
    func titleForFollowState(state: FollowTwitterButtonState) -> String {
        switch state {
        case .Checking: return "Checking if following..."
        case .Follow: return "  Follow \(username) on twitter "
        case .SendingRequest: return "Sending request..."
        case .Following: return "  Following \(username)  "
        }
    }
    
}