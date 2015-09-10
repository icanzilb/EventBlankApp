//
//  EANavigationController.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/8/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class EANavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
