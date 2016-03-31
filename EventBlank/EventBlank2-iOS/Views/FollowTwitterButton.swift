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
    case Checking, SendingRequest, NA
    case NotFollowing(String)
    case Following(String)
}

extension CALayer {
    public var rx_borderColor: AnyObserver<CGColor?> {
        return UIBindingObserver(UIElement: self) { layer, color in
            layer.borderColor = color
        }.asObserver()
    }
}

class FollowTwitterButton: UIButton {

    private let bag = DisposeBag()
    
    // MARK: input
    let rx_following = PublishSubject<FollowingOnTwitter>()
    
    // MARK: life cycle
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
        rx_following.map(colorForFollowState)
            .map { $0.CGColor }
            .bindTo(layer.rx_borderColor)
            .addDisposableTo(bag)
        
        rx_following.map(titleForFollowState)
            .bindNext {[weak self] title in
                self?.setTitle(title, forState: .Normal)
            }.addDisposableTo(bag)
        
        rx_following.map(colorForFollowState)
            .bindNext {[weak self] color in
                self?.setTitleColor(color, forState: .Normal)
            }.addDisposableTo(bag)
    }
    
    // MARK: private
    private func colorForFollowState(state: FollowingOnTwitter) -> UIColor {
        switch state {
            case .Checking: return UIColor.orangeColor()
            case .NotFollowing: return UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
            case .SendingRequest: return UIColor.darkGrayColor()
            case .Following: return UIColor.blueColor()
            case .NA: return UIColor.lightGrayColor()
        }
    }
    
    private func titleForFollowState(state: FollowingOnTwitter) -> String {
        switch state {
            case .Checking: return "Checking..."
            case .NotFollowing(let username): return "  Follow \(username) on twitter "
            case .SendingRequest: return "Sending request..."
            case .Following(let username): return "  Following \(username)  "
            case .NA: return "  n/a  "
        }
    }
    
}