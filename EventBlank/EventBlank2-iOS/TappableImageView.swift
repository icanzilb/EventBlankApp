//
//  TappableImageView.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/27/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TappableImageView: UIImageView {
    
    var tap: UITapGestureRecognizer!
    
    override func didMoveToSuperview() {
        userInteractionEnabled = true
        if let _ = superview {
            tap = UITapGestureRecognizer(target: self, action: "didTap")
            addGestureRecognizer(tap)
        } else {
            removeGestureRecognizer(tap)
        }
    }
    
    func didTap() {
        rx_tap.onNext()
    }
    
    var rx_tap = PublishSubject<Void>()
}