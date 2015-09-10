//
//  TabStripNavigationController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit

class TabStripNavigationController: UINavigationController {

    //MARK: - page strip
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        if viewControllers.count > 1 {
            setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        let result = super.popViewControllerAnimated(animated)
        
        if viewControllers.count == 1 {
            setNavigationBarHidden(true, animated: true)
        }
        
        return result
    }
}
