//
//  FeedViewController+Pager.swift
//  EventBlank
//
//  Created by Marin Todorov on 9/10/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import KHTabPagerViewController

extension FeedViewController: KHTabPagerDelegate {
    func tabPager(tabPager: KHTabPagerViewController!, didTransitionToTabAtIndex index: Int) {
        updateComposeButtonHidden()
    }
}

extension FeedViewController: KHTabPagerDataSource {
    func numberOfViewControllers() -> Int {
        //check if needs to show audience chatter
        if Event.event[Event.twitterChatter] < 1 {
            return 1
        } else {
            return 2
        }
    }
    
    func viewControllerForIndex(index: Int) -> UIViewController! {
        if index == 0 {
            return self.storyboard!.instantiateViewControllerWithIdentifier("NewsNavigationController")! as! UINavigationController
        }
        if index == 1 {
            return self.storyboard!.instantiateViewControllerWithIdentifier("ChatNavigationController")! as! UINavigationController
        }
        return nil
    }
    
    func titleForTabAtIndex(index: Int) -> String! {
        if index==0 {
            return "  News  "
        } else {
            return "  Chatter  "
        }
    }
    
    func tabBackgroundColor() -> UIColor! {
        return UIColor(hexString: Event.event[Event.mainColor])
    }
    
    func tabColor() -> UIColor! {
        return UIColor(hexString: Event.event[Event.mainColor]).lighterColor().lighterColor()
    }
    
    func titleColor() -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func titleFont() -> UIFont! {
        return UIFont.systemFontOfSize(18.0)
    }
    
    func tabHeight() -> CGFloat {
        return 64.0
    }
    
    func tabBarTopView() -> UIView! {
        let headerView = UIView()
        headerView.backgroundColor = tabBackgroundColor()
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 20)
        return headerView
    }
    
    func viewForTabAtIndex(index: Int) -> UIView! {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: tabHeight()))
        
        let l = UILabel()
        l.font = titleFont()
        l.text = titleForTabAtIndex(index)
        l.textColor = UIColor.whiteColor()
        l.backgroundColor = UIColor.clearColor()
        l.sizeToFit()
        l.center.y = v.frame.size.height - l.frame.size.height/2 - 10
        
        v.frame.size.width = l.frame.size.width * 1.4
        l.center.x = v.frame.size.width/2
        v.addSubview(l)
        return v
    }
}
