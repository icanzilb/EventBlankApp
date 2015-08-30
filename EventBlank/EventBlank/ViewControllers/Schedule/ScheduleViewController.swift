//
//  ScheduleViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/19/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

import XLPagerTabStrip

let kScrollToCurrentSessionNotification = "kScrollToCurrentSessionNotification"

protocol SessionViewControllerDelegate {
    func isFavoritesFilterOn() -> Bool
}

class ScheduleViewController: XLButtonBarPagerTabStripViewController, XLPagerTabStripViewControllerDataSource, SessionViewControllerDelegate {

    var isReloading = false
    var btnFavorites = UIButton()
    
    var event: Row {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).event
        }

    var initialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonBarView.registerNib(UINib(nibName: "NavTabButtonCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        //notifications
        observeNotification(kDidReplaceEventFileNotification, selector: "didChangeEventFile")
        observeNotification(kShowCurrentSessionNotification, selector: "showCurrentSession")
    }
    
    deinit {
        observeNotification(kDidReplaceEventFileNotification, selector: nil)
        observeNotification(kShowCurrentSessionNotification, selector: nil)
    }
    
    func setupUI() {
        //set up the tab strip
        self.isProgressiveIndicator = true
        self.buttonBarView.backgroundColor = UIColor.clearColor()
        self.buttonBarView.selectedBar.backgroundColor = UIColor(hexString: event[Event.mainColor]).lighterColor()

        if let _ = btnFavorites.superview {
            btnFavorites.layer.removeFromSuperlayer()
            btnFavorites = UIButton()
        }
        
        //set up the fav button
        btnFavorites.frame = CGRect(x: navigationController!.navigationBar.bounds.size.width - 40, y: 0, width: 40, height: 40)
        
        btnFavorites.setImage(UIImage(named: "like-empty")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        btnFavorites.setImage(UIImage(named: "like-full")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Selected)
        btnFavorites.addTarget(self, action: Selector("actionToggleFavorites:"), forControlEvents: .TouchUpInside)
        btnFavorites.tintColor = UIColor.whiteColor()
        
        buttonBarView.addSubview(btnFavorites)
        
        //add button background
        let gradient = CAGradientLayer()
        gradient.frame = btnFavorites.bounds
        gradient.colors = [UIColor(hexString: event[Event.mainColor]).colorWithAlphaComponent(0.1).CGColor, UIColor(hexString: event[Event.mainColor]).CGColor]
        gradient.locations = [0, 0.25]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        btnFavorites.layer.insertSublayer(gradient, below: btnFavorites.imageView!.layer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !initialized {
            initialized = true
            
            setupUI()
            
            //TODO: why?
            moveToViewControllerAtIndex(1)
            moveToViewControllerAtIndex(0)
            
        }

        //add tab strip
        navigationController?.navigationBar.addSubview(btnFavorites)
        navigationController?.navigationBar.insertSubview(buttonBarView, belowSubview: btnFavorites)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animateWithDuration(0.33, delay: 0.0, options: .CurveEaseIn, animations: {
            self.btnFavorites.alpha = 0.0
            self.btnFavorites.transform = CGAffineTransformMakeTranslation(-50.0, 0.0)
            self.buttonBarView.alpha = 0.0
            self.buttonBarView.transform = CGAffineTransformMakeTranslation(-50.0, 0.0)
        }, completion: {_ in
            self.buttonBarView.removeFromSuperview()
            self.buttonBarView.transform = CGAffineTransformIdentity
            self.buttonBarView.alpha = 1.0
            self.btnFavorites.removeFromSuperview()
            self.btnFavorites.transform = CGAffineTransformIdentity
            self.btnFavorites.alpha = 1.0
        })
    }
    
    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        
        return Schedule().dayRanges().map {
            let dayVC = self.storyboard!.instantiateViewControllerWithIdentifier("SessionsViewController")! as! SessionsViewController
            dayVC.title = $0.text
            dayVC.day = $0
            dayVC.delegate = self
            return dayVC
        }
    }

    func actionToggleFavorites(sender: AnyObject) {
        btnFavorites.selected = !btnFavorites.selected
        btnFavorites.animateSelect(scale: 0.8, completion: {
            self.notification(kFavoritesToggledNotification, object: nil)
        })
    }
    
    //MARK: - session view controller methods
    func isFavoritesFilterOn() -> Bool {
        return btnFavorites.selected
    }
 
    //notifications
    func didChangeEventFile() {
        setupUI()
        reloadPagerTabStripView()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func showCurrentSession() {
        let days = Schedule().dayRanges()
        let now = NSDate().timeIntervalSince1970
        
        for index in 0 ..< days.count {
            let day = days[index]
            
            if now > day.startTimeStamp && now < day.endTimeStamp {
                mainQueue({
                    self.moveToViewControllerAtIndex(UInt(index))
                    self.notification(kScrollToCurrentSessionNotification, object: day.text)
                })
                
                return
            }
        }
    }
}