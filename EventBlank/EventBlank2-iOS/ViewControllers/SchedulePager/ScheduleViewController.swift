//
//  ScheduleViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 4/9/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ScheduleViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .clearColor()
        settings.style.selectedBarBackgroundColor = .orangeColor()
        settings.style.buttonBarItemsShouldFillAvailiableWidth = false
        
        super.viewDidLoad()
        
        buttonBarView.removeFromSuperview()
        navigationController?.navigationBar.addSubview(buttonBarView)
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .whiteColor()
            
            if animated {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
                })
            }
            else {
                newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }
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
