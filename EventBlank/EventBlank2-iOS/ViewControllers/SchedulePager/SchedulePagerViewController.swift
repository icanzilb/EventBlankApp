//
//  SchedulePagerViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import KHTabPagerViewController
import Then

class SchedulePagerViewController: KHTabPagerViewController {
//class SchedulePagerViewController: PagerController, PagerDataSource {
    
    private var controllers: [EANavigationController]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        controllers =  Schedule().dayRanges().map {day in
            return EANavigationController(rootViewController:
                SessionsViewController.createWith(self.storyboard!, day: day)
            )
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    deinit {
        dataSource = nil
    }
}

extension SchedulePagerViewController: KHTabPagerDelegate {
    func tabPager(tabPager: KHTabPagerViewController!, didTransitionToTabAtIndex index: Int) {
        
    }
}

extension SchedulePagerViewController: KHTabPagerDataSource {
    func numberOfViewControllers() -> Int {
        print("\(controllers.count) tabs")
        return controllers.count
    }
    
    func viewControllerForIndex(index: Int) -> UIViewController! {
        return controllers[index]
    }
    
    func titleForTabAtIndex(index: Int) -> String! {
        return controllers[index].title
    }
    
    func tabBackgroundColor() -> UIColor! {
        //return UIColor(hexString: Event.event[Event.mainColor])
        return UIColor.lightGrayColor()
    }
    
    func tabColor() -> UIColor! {
        //return UIColor(hexString: Event.event[Event.mainColor]).lighterColor().lighterColor()
        return UIColor.grayColor()
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
