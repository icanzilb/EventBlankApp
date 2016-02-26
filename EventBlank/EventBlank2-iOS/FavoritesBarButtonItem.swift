//
//  FavoritesBarButtonItem.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/25/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class FavoritesBarButtonItem: UIBarButtonItem {

    let bag = DisposeBag()
    var button: UIButton!
    
    static func instance() -> FavoritesBarButtonItem {
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        button.setImage(UIImage(named: "like-empty")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        button.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        button.tintColor = UIColor.whiteColor()
        
        let barItem = FavoritesBarButtonItem(customView: button)
        barItem.button = button
        barItem.bindUI()
        return barItem
    }
    
    func bindUI() {
        precondition(button != nil)
        
        let btnTap = button.rx_tap.scan(false, accumulator: {acc, _ in
            return !acc
        })
        
        btnTap.bindTo(button.rx_selected).addDisposableTo(bag)
    }
    
    var selected: Bool {
        get {
            return button.selected
        }
        set {
            button.selected = newValue
        }
    }
    
    var rx_selected: AnyObserver<Bool> {
        get {
            return button.rx_selected
        }
    }
}