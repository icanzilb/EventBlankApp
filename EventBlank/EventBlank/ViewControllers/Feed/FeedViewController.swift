//
//  FeedViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/21/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FeedViewController: XLSegmentedPagerTabStripViewController, XLPagerTabStripViewControllerDataSource, UIScrollViewDelegate {

    @IBOutlet weak var tabControl: UISegmentedControl!
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        self.skipIntermediateViewControllers = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        //notifications
        observeNotification(kDidReplaceEventFileNotification, selector: "didChangeEventFile")
    }

    deinit {
        //notifications
        observeNotification(kDidReplaceEventFileNotification, selector: nil)
    }
    
    func setupUI() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: why?
        moveToViewControllerAtIndex(1)
        moveToViewControllerAtIndex(0)
        
    }

    override func childViewControllersForPagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController!) -> [AnyObject]! {
        let newsVC = self.storyboard!.instantiateViewControllerWithIdentifier("NewsNavigationController")! as! TabStripNavigationController
        let chatterVC = self.storyboard!.instantiateViewControllerWithIdentifier("ChatNavigationController")! as! TabStripNavigationController
        return [newsVC, chatterVC]
    }

    @IBAction func actionChangeSelectedSegment(sender: AnyObject) {
        if let sender = sender as? UISegmentedControl {
            moveToViewControllerAtIndex(UInt(sender.selectedSegmentIndex))
        }
    }
    
    //MARK: - scroll view methods
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentPage = lround(Double(scrollView.contentOffset.x / scrollView.frame.size.width))
        tabControl.selectedSegmentIndex = currentPage        
    }
    
    //notifications
    func didChangeEventFile() {
        reloadPagerTabStripView()
        navigationController?.popToRootViewControllerAnimated(true)
    }
}
