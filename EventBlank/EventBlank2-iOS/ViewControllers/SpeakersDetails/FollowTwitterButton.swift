//
//  FollowTwitterButton.swift
//  EventBlank
//
//  Created by Marin Todorov on 8/23/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

enum FollowingOnTwitter {
    case Checking, NotFollowing, SendingRequest, Following, NA
}

extension CALayer {
    public var rx_borderColor: AnyObserver<CGColor?> {
        return UIBindingObserver(UIElement: self) { layer, color in
            layer.borderColor = color
        }.asObserver()
    }
}

class FollowTwitterButton: UIButton {

    var username: String!

    let bag = DisposeBag()
    
    //
    // input
    //
    
    var rx_following = PublishSubject<FollowingOnTwitter>()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard superview != nil else {
            return
        }
        
        setupUI()
        bindUI()
    }
    
    func setupUI() {
        layer.cornerRadius = 5.0
        layer.borderWidth = 1.0
        backgroundColor = UIColor.whiteColor()
    }

    func bindUI() {
        rx_following.map(colorForFollowState) .map { $0.CGColor } .bindTo(layer.rx_borderColor).addDisposableTo(bag)
        rx_following.map(titleForFollowState) .bindNext {[unowned self] title in
            self.setTitle(title, forState: .Normal)
        } .addDisposableTo(bag)
        rx_following.map(colorForFollowState) .bindNext {[unowned self] color in
            self.setTitleColor(color, forState: .Normal)
        } .addDisposableTo(bag)
    }
    
    func colorForFollowState(state: FollowingOnTwitter) -> UIColor {
        switch state {
            case .Checking: return UIColor.orangeColor()
            case .NotFollowing: return UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
            case .SendingRequest: return UIColor.darkGrayColor()
            case .Following: return UIColor.blueColor()
            case .NA: return UIColor.lightGrayColor()
        }
    }
    
    func titleForFollowState(state: FollowingOnTwitter) -> String {
        switch state {
        case .Checking: return "Checking if following..."
        case .NotFollowing: return "  Follow \(username) on twitter "
        case .SendingRequest: return "Sending request..."
        case .Following: return "  Following \(username)  "
        case .NA: return "  n/a  "
        }
    }
    
}