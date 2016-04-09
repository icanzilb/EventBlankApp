//
//  SchedulePagerViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import Pager
import Then

class SchedulePagerViewController: PagerController, PagerDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        let controllers =  Schedule().dayRanges().map {day in
            return EANavigationController(rootViewController:
                SessionsViewController.createWith(self.storyboard!, day: day)
            )
        }

        setupPager(
            tabNames: controllers.map {$0.title!},
            tabControllers: controllers)
        
        setupUI()
    }

    func setupUI()
    {
        indicatorColor = UIColor.whiteColor()
        tabsViewBackgroundColor = UIColor.redColor()
        contentViewBackgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.32)
        
        startFromSecondTab = false
        centerCurrentTab = false
        tabLocation = PagerTabLocation.Top
        tabHeight = 49
        tabOffset = 36
        tabWidth = 96.0
        fixFormerTabsPositions = false
        fixLaterTabsPosition = false
        animation = PagerAnimation.During
    }

    deinit {
        dataSource = nil
    }
}