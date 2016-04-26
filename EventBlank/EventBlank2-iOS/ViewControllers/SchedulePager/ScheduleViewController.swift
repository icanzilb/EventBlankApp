//
//  ScheduleViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import XLPagerTabStrip

import RxSwift
import RxCocoa

class ScheduleViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        setupUI()
        super.viewDidLoad()
    }

    func setupUI() {
        let event = EventData.defaultEvent
        
        settings.style.buttonBarBackgroundColor = .clearColor()
        settings.style.selectedBarBackgroundColor = event.mainColor.lightenColor(0.25)
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        
        buttonBarView.removeFromSuperview()
        navigationController?.navigationBar.addSubview(buttonBarView)
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .whiteColor()
        }
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return Schedule().dayRanges().map {day in
            return SessionsViewController.createWith(self.storyboard!, day: day, visibilityCallback: shouldShowButtonBar)
        }
    }
    
    override func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo) {
        super.configureCell(cell, indicatorInfo: indicatorInfo)
        cell.backgroundColor = .clearColor()
    }
    
    func shouldShowButtonBar(visible: Bool) {
        UIView.transitionWithView(self.buttonBarView, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.buttonBarView.hidden = !visible
        }, completion: nil)
    }
}
