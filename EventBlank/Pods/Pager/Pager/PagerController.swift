//
//  ViewPager.swift
//  Pager
//
//  Created by Lucas Oceano on 12/03/2015.
//  Copyright (c) 2015 Cheesecake. All rights reserved.
//

import Foundation
import UIKit.UITableView

//MARK: - Pager Enums
//Enum for the location of the tab bar
public enum PagerTabLocation: Int {
  case None = 0 //None will go to the bottom
  case Top = 1
  case Bottom = 2
}

//Enum for the animation of the tab indicator
public enum PagerAnimation: Int {
  case None = 0 // No animation
  case End = 1 //pager indicator will animate after the VC changes
  case During = 2 //pager indicator will animate as the VC changes
}

//MARK: - Protocols
@objc public protocol PagerDelegate: NSObjectProtocol {
	optional func didChangeTabToIndex(pager: PagerController, index: Int)
	optional func didChangeTabToIndex(pager: PagerController, index: Int, previousIndex: Int)
	optional func didChangeTabToIndex(pager: PagerController, index: Int, previousIndex: Int, swipe: Bool)
}

@objc public protocol PagerDataSource: NSObjectProtocol {
	optional func numberOfTabs(pager: PagerController) -> Int
	optional func tabViewForIndex(index: Int, pager: PagerController) -> UIView
	optional func viewForTabAtIndex(index: Int, pager: PagerController) -> UIView
	optional func controllerForTabAtIndex(index: Int, pager: PagerController) -> UIViewController
}

public class PagerController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {

  // MARK: - public properties
	public var contentViewBackgroundColor: UIColor = UIColor.whiteColor()
	public var indicatorColor: UIColor = UIColor.redColor()
	public var tabsViewBackgroundColor: UIColor = UIColor.grayColor()
	public var dataSource: PagerDataSource!
	public var delegate: PagerDelegate?
	public var tabHeight: CGFloat = 44.0
	public var tabOffset: CGFloat = 56.0
	public var tabWidth: CGFloat = 128.0
	public var indicatorHeight: CGFloat = 5.0
	public var tabLocation: PagerTabLocation = PagerTabLocation.Top
	public var animation: PagerAnimation = PagerAnimation.During
	public var startFromSecondTab: Bool = false
	public var centerCurrentTab: Bool = false
	public var fixFormerTabsPositions: Bool = false
	public var fixLaterTabsPosition: Bool = false
	private var tabNames: [String] = []
	private var tabControllers: [UIViewController] = []

  // MARK: - Tab and content stuff
	internal var tabsView: UIScrollView?
	internal var pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
	internal var actualDelegate: UIScrollViewDelegate?
	internal var contentView: UIView {
		let contentView = self.pageViewController.view
		contentView!.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
		contentView!.backgroundColor = self.contentViewBackgroundColor
		contentView!.bounds = self.view.bounds
		contentView!.tag = 34

		return contentView
	}

  // MARK: - Tab and content cache
	internal var underlineStroke: UIView = UIView()
	internal var tabs: [UIView?] = []
	internal var contents: [UIViewController?] = []
	internal var tabCount: Int = 0
	internal var activeTabIndex: Int = 0
	internal var activeContentIndex: Int = 0
	internal var animatingToTab: Bool = false
	internal var defaultSetupDone: Bool = false
	internal var didTapOnTabView: Bool = false

	// MARK: - Important Methods
	// TODO: Find a good place to put this method
	/// Initializing PagerController with Name of the Tabs and their respective ViewControllers
  public func setupPager(tabNames tabNames: [String], tabControllers: [UIViewController])
  {
    self.tabNames = tabNames
    self.tabControllers = tabControllers
  }
  
  public func reloadData() {
    self.defaultSetup()
    self.view.setNeedsDisplay()
  }
  
  public func selectTabAtIndex(index: Int) {
    self .selectTabAtIndex(index, swipe: false)
  }

  //MARK: - Other Methods
	override public func viewDidLoad() {
		super.viewDidLoad()
		self.defaultSettings()
	}

	override public func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if !self.defaultSetupDone {
			self.defaultSetup()
		}
	}

	override public func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		self.layoutSubViews()
	}

	override public func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
		super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
		self.layoutSubViews()
		self.changeActiveTabIndex(self.activeTabIndex)
	}

	override public func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

  //MARK: - Private Methods
	func defaultSettings() {
		for (view): (UIView) in self.pageViewController.view!.subviews as [UIView] {
			if view is UIScrollView {
				self.actualDelegate = (view as! UIScrollView).delegate
				(view as! UIScrollView).delegate = self
			}
		}

		self.pageViewController.dataSource = self
		self.pageViewController.delegate = self
	}

	func defaultSetup() {
		// Empty tabs and contents
		for tabView in self.tabs {
			tabView?.removeFromSuperview()
		}

		self.tabs.removeAll(keepCapacity: true)
		self.contents.removeAll(keepCapacity: true)
		self.underlineStroke.removeFromSuperview()

		// Get tabCount from dataSource

		if let num = self.dataSource!.numberOfTabs?(self)
		{
			self.tabCount = num
		}
		else
		{
			self.tabCount = tabControllers.count
		}

		// Populate arrays with nil
		self.tabs = Array(count: self.tabCount, repeatedValue: nil)
		for _ in 0 ..< self.tabCount {
			self.tabs.append(nil)
		}

		self.contents = Array(count: self.tabCount, repeatedValue: nil)
		for _ in 0 ..< self.tabCount {
			self.contents.append(nil)
		}

		// Add tabsView
		if self.tabsView == nil {

			self.tabsView = UIScrollView(frame: CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), self.tabHeight))
			self.tabsView!.autoresizingMask = .FlexibleWidth
			self.tabsView!.backgroundColor = self.tabsViewBackgroundColor
			self.tabsView!.scrollsToTop = false
			self.tabsView?.bounces = false
			self.tabsView!.showsHorizontalScrollIndicator = false
			self.tabsView!.showsVerticalScrollIndicator = false
			self.tabsView!.tag = 38

			self.view.insertSubview(self.tabsView!, atIndex: 0)
		} else {
			self.tabsView = self.view.viewWithTag(38) as? UIScrollView
		}

		// Add tab views to _tabsView
		var contentSizeWidth: CGFloat = 0.0

		// Give the standard offset if fixFormerTabsPositions is provided as YES
		if (self.fixFormerTabsPositions) {
			// And if the centerCurrentTab is provided as YES fine tune the offset according to it
			if (self.centerCurrentTab) {
				contentSizeWidth = (CGRectGetWidth(self.tabsView!.frame) - self.tabWidth) / 2.0
			} else {
				contentSizeWidth = self.tabOffset
			}
		}

		for i in 0 ..< self.tabCount {
			let tabView: UIView? = self.tabViewAtIndex(i) as UIView?
			var frame: CGRect = tabView!.frame
			frame.origin.x = contentSizeWidth
			frame.size.width = self.tabWidth
			tabView!.frame = frame

			self.tabsView!.addSubview(tabView!)

			contentSizeWidth += CGRectGetWidth(tabView!.frame)

			// To capture tap events
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PagerController.handleTapGesture(_:)))
			tabView!.addGestureRecognizer(tapGestureRecognizer)
		}

		// Extend contentSizeWidth if fixLatterTabsPositions is provided YES
		if (self.fixLaterTabsPosition) {
			// And if the centerCurrentTab is provided as YES fine tune the content size according to it
			if (self.centerCurrentTab) {
				contentSizeWidth += (CGRectGetWidth(self.tabsView!.frame) - self.tabWidth) / 2.0
			} else {
				contentSizeWidth += CGRectGetWidth(self.tabsView!.frame) - self.tabWidth - self.tabOffset
			}
		}

		self.tabsView!.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight)

		self.view.insertSubview(self.contentView, atIndex: 0)

		// Select starting tab
		let index: Int = self.startFromSecondTab ? 1 : 0
		self.selectTabAtIndex(index, swipe: true)

		if (self.tabCount > 0) {
			// creates the indicator
			var rect: CGRect = self.tabViewAtIndex(self.activeContentIndex)!.frame
			rect.origin.y = rect.size.height - self.indicatorHeight
			rect.size.height = self.indicatorHeight

			self.underlineStroke = UIView(frame: rect)
			self.underlineStroke.backgroundColor = self.indicatorColor
			self.tabsView!.addSubview(self.underlineStroke)
		}

		// Set setup done
		self.defaultSetupDone = true
	}

	func layoutSubViews() {
		var topLayoutGuide: CGFloat = 0.0
		if (self.navigationController?.navigationBar.translucent != false) {
			topLayoutGuide = UIApplication.sharedApplication().statusBarHidden ? 0.0 : 20.0
			topLayoutGuide += self.navigationController!.navigationBar.frame.size.height
		}

		var frame: CGRect = self.tabsView!.frame
		frame.origin.x = 0.0
		frame.origin.y = (self.tabLocation == .Top) ? topLayoutGuide : CGRectGetHeight(self.view.frame) - self.tabHeight
		frame.size.width = CGRectGetWidth(self.view.frame)
		frame.size.height = self.tabHeight
		self.tabsView!.frame = frame

		frame = self.contentView.frame
		frame.origin.x = 0.0
		frame.origin.y = (self.tabLocation == .Top) ? topLayoutGuide + CGRectGetHeight(self.tabsView!.frame): topLayoutGuide
		frame.size.width = CGRectGetWidth(self.view.frame)

		frame.size.height = CGRectGetHeight(self.view.frame) - (topLayoutGuide + CGRectGetHeight(self.tabsView!.frame))

		if (self.tabBarController != nil) {
			frame.size.height -= CGRectGetHeight(self.tabBarController!.tabBar.frame)
		}

		self.contentView.frame = frame
	}
	func indexForViewController(viewController: UIViewController) -> Int {
		for (index, element) in self.contents.enumerate() {
			if (element == viewController) {
				return index
			}
		}
		return 0
	}

	func selectTabAtIndex(index: Int, swipe: Bool) {
		if (index >= self.tabCount) {
			return
		}

		self.didTapOnTabView = !swipe
		self.animatingToTab = true

		let previousIndex: Int = self.activeTabIndex

		self.changeActiveTabIndex(index)
		self.setActiveContentIndex(index)

		if self.delegate != nil {
			if (self.delegate!.respondsToSelector(Selector("didChangeTabToIndex:didChangeTabToIndex:"))) {
				self.delegate!.didChangeTabToIndex!(self, index: index)
			} else if (self.delegate!.respondsToSelector(Selector("didChangeTabToIndex:didChangeTabToIndex:fromIndex:"))) {
				self.delegate!.didChangeTabToIndex!(self, index: index, previousIndex: previousIndex)
			} else if (self.delegate!.respondsToSelector(Selector("didChangeTabToIndex:didChangeTabToIndex:fromIndex:didSwipe:"))) {
				self.delegate!.didChangeTabToIndex!(self, index: index, previousIndex: previousIndex, swipe: swipe)
			}
		}
	}

	func changeActiveTabIndex(newIndex: Int) {

		self.activeTabIndex = newIndex

		let tabView: UIView = self.tabViewAtIndex(self.activeTabIndex)!
		var frame: CGRect = tabView.frame

		if (self.centerCurrentTab) {
			frame.origin.x += (CGRectGetWidth(frame) / 2)
			frame.origin.x -= (CGRectGetWidth(self.tabsView!.frame) / 2)

			if (frame.origin.x < 0) {
				frame.origin.x = 0
			}

			if ((frame.origin.x + CGRectGetWidth(frame)) > self.tabsView!.contentSize.width) {
				frame.origin.x = (self.tabsView!.contentSize.width - CGRectGetWidth(self.tabsView!.frame))
			}
		} else {
			frame.origin.x -= self.tabOffset
			frame.size.width = CGRectGetWidth(self.tabsView!.frame)
		}

		self.tabsView!.scrollRectToVisible(frame, animated: true)
	}

	func tabViewAtIndex(index: Int) -> TabView? {
		if (index >= self.tabCount) {
			return nil
		}

		if (self.tabs[index] as UIView?) == nil {

			var tabViewContent = UIView()
			if let tab = self.dataSource.tabViewForIndex?(index, pager: self)
			{
				tabViewContent = tab
			}
			else
			{
				let title = self.tabNames[index]

				let label: UILabel = UILabel()
				label.text = title;
				label.textColor = UIColor.whiteColor()
				label.font = UIFont.boldSystemFontOfSize(16.0)
				label.backgroundColor = UIColor.clearColor()
				label.sizeToFit()
				tabViewContent = label
			}
			tabViewContent.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]

			let tabView: TabView = TabView(frame: CGRectMake(0.0, 0.0, self.tabWidth, self.tabHeight))
			tabView.addSubview(tabViewContent)
			tabView.clipsToBounds = true
			tabViewContent.center = tabView.center

			// Replace the null object with tabView
			self.tabs[index] = tabView
		}

		return self.tabs[index] as? TabView
	}

	func setNeedsReloadOptions() {
		// We should update contentSize property of our tabsView, so we should recalculate it with the new values
		var contentSizeWidth: CGFloat = 0.0

		// Give the standard offset if fixFormerTabsPositions is provided as YES
		if (self.fixFormerTabsPositions) {
			// And if the centerCurrentTab is provided as YES fine tune the offset according to it
			if (self.centerCurrentTab) {
				contentSizeWidth = (CGRectGetWidth(self.tabsView!.frame) - self.tabWidth) / 2.0
			} else {
				contentSizeWidth = self.tabOffset
			}
		}

		// Update every tab's frame
		for i in 0 ..< self.tabCount {
			let tabView = self.tabViewAtIndex(i)
			var frame: CGRect = tabView!.frame
			frame.origin.x = contentSizeWidth
			frame.size.width = self.tabWidth
			tabView?.frame = frame
			contentSizeWidth += CGRectGetWidth(tabView!.frame)
		}

		// Extend contentSizeWidth if fixLatterTabsPositions is provided YES
		if (self.fixLaterTabsPosition) {

			// And if the centerCurrentTab is provided as YES fine tune the content size according to it
			if (self.centerCurrentTab) {
				contentSizeWidth += (CGRectGetWidth(self.tabsView!.frame) - self.tabWidth) / 2.0
			} else {
				contentSizeWidth += CGRectGetWidth(self.tabsView!.frame) - self.tabWidth - self.tabOffset
			}
		}
		// Update tabsView's contentSize with the new width
		self.tabsView!.contentSize = CGSizeMake(contentSizeWidth, self.tabHeight)
	}

	func viewControllerAtIndex(index: Int) -> UIViewController? {
		if (index >= self.tabCount || index < 0) {
			return nil
		}

		if (self.contents[index] as UIViewController?) == nil {
			var viewController: UIViewController

			if (self.dataSource!.respondsToSelector(#selector(PagerDataSource.controllerForTabAtIndex(_:pager:)))) {
				viewController = self.dataSource.controllerForTabAtIndex!(index, pager: self)
			} else if (self.dataSource!.respondsToSelector(#selector(PagerDataSource.viewForTabAtIndex(_:pager:)))) {

				let view: UIView = self.dataSource.viewForTabAtIndex!(index, pager: self)

				// Adjust view's bounds to match the pageView's bounds
				let pageView: UIView = self.view.viewWithTag(34)!
				view.frame = pageView.bounds

				viewController = UIViewController()
				viewController.view = view
			} else {
				viewController = self.tabControllers[index]
			}
			self.contents[index] = viewController
			self.pageViewController.addChildViewController(viewController)
		}
		return self.contents[index]
	}
  
  
  //MARK: - Gestures
  @IBAction func handleTapGesture(sender: UITapGestureRecognizer) {
    let tabView: UIView = sender.view!
    
    let index: Int = self.tabs.find {
      $0 as UIView? == tabView
      }!
    
    if (self.activeTabIndex != index) {
      self.selectTabAtIndex(index)
    }
  }


  //MARK: - Page DataSource
	public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		var index: Int = self.indexForViewController(viewController)
		index -= 1
		return self.viewControllerAtIndex(index)
	}

	public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		var index: Int = self.indexForViewController(viewController)
		index += 1
		return self.viewControllerAtIndex(index)
	}

  //MARK: - Page Delegate
	public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		let viewController: UIViewController = self.pageViewController.viewControllers![0] as UIViewController
		let index: Int = self.indexForViewController(viewController)
		self.selectTabAtIndex(index, swipe: true)
	}

	@nonobjc func setActiveContentIndex(activeContentIndex: Int) {
		// Get the desired viewController
		var viewController: UIViewController? = self.viewControllerAtIndex(activeContentIndex)!
		if (viewController == nil) {
			viewController = UIViewController()
			viewController!.view = UIView()
			viewController!.view.backgroundColor = UIColor.clearColor()
		}

		weak var wPageViewController: UIPageViewController? = self.pageViewController
		weak var wSelf: PagerController? = self

		if (activeContentIndex == self.activeContentIndex) {
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in

				self.pageViewController.setViewControllers([viewController!], direction: .Forward, animated: false, completion: {
					(completed: Bool) -> Void in
					wSelf!.animatingToTab = false
				})
			})
		} else if (!(activeContentIndex + 1 == self.activeContentIndex || activeContentIndex - 1 == self.activeContentIndex)) {

			let direction: UIPageViewControllerNavigationDirection = (activeContentIndex < self.activeContentIndex) ? .Reverse : .Forward
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in

				self.pageViewController.setViewControllers([viewController!], direction: direction, animated: true, completion: {
					(completed: Bool) -> Void in

					wSelf?.animatingToTab = false

					dispatch_async(dispatch_get_main_queue(), {
						() -> Void in
						wPageViewController!.setViewControllers([viewController!], direction: direction, animated: false, completion: nil)
					})
				})
			})
		} else {
			let direction: UIPageViewControllerNavigationDirection = (activeContentIndex < self.activeContentIndex) ? .Reverse : .Forward
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in

				self.pageViewController.setViewControllers([viewController!], direction: direction, animated: true, completion: {
					(completed: Bool) -> Void in
					wSelf!.animatingToTab = true
				})
			})
		}

		// Clean out of sight contents
		var index: Int = self.activeContentIndex - 1
		if (index >= 0 && index != activeContentIndex && index != activeContentIndex - 1) {
			self.contents[index] = nil
		}
		index = self.activeContentIndex
		if (index != activeContentIndex - 1 && index != activeContentIndex && index != activeContentIndex + 1) {
			self.contents[index] = nil
		}
		index = self.activeContentIndex + 1
		if (index < self.contents.count && index != activeContentIndex && index != activeContentIndex + 1) {
			self.contents[index] = nil
		}
		self.activeContentIndex = activeContentIndex
	}

  //MARK: - UIScrollViewDelegate
  //MARK: Responding to Scrolling and Dragging
	public func scrollViewDidScroll(scrollView: UIScrollView) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)))) {
				self.actualDelegate!.scrollViewDidScroll!(scrollView)
			}
		}

		let tabView: UIView = self.tabViewAtIndex(self.activeTabIndex)!

		if (!self.animatingToTab) {

			// Get the related tab view position
			var frame: CGRect = tabView.frame
			let movedRatio: CGFloat = (scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame)) - 1
			frame.origin.x += movedRatio * CGRectGetWidth(frame)

			if (self.centerCurrentTab) {

				frame.origin.x += (frame.size.width / 2)
				frame.origin.x -= CGRectGetWidth(self.tabsView!.frame) / 2
				frame.size.width = CGRectGetWidth(self.tabsView!.frame)

				if (frame.origin.x < 0) {
					frame.origin.x = 0
				}

				if ((frame.origin.x + frame.size.width) > self.tabsView!.contentSize.width) {
					frame.origin.x = (self.tabsView!.contentSize.width - CGRectGetWidth(self.tabsView!.frame))
				}
			} else {

				frame.origin.x -= self.tabOffset
				frame.size.width = CGRectGetWidth(self.tabsView!.frame)
			}

			self.tabsView!.scrollRectToVisible(frame, animated: false)
		}

		var rect: CGRect = tabView.frame

		let updateIndicator = {
			(newX: CGFloat) -> Void in
			rect.origin.x = newX
			rect.origin.y = self.underlineStroke.frame.origin.y
			rect.size.height = self.underlineStroke.frame.size.height
			self.underlineStroke.frame = rect
		}

		var newX: CGFloat
		let width: CGFloat = CGRectGetWidth(self.view.frame)
		let distance: CGFloat = tabView.frame.size.width

		if (self.animation == PagerAnimation.During && !self.didTapOnTabView) {
			if (scrollView.panGestureRecognizer.translationInView(scrollView.superview!).x > 0) {
				let mov: CGFloat = width - scrollView.contentOffset.x
				newX = rect.origin.x - ((distance * mov) / width)
			} else {
				let mov: CGFloat = scrollView.contentOffset.x - width
				newX = rect.origin.x + ((distance * mov) / width)
			}
			updateIndicator(newX)
		} else if (self.animation == PagerAnimation.None) {
			newX = tabView.frame.origin.x
			updateIndicator(newX)
		} else if (self.animation == PagerAnimation.End || self.didTapOnTabView) {
			newX = tabView.frame.origin.x
			UIView.animateWithDuration(0.35, animations: {
				() -> Void in
				updateIndicator(newX)
			})
		}
	}

	public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))) {
				self.actualDelegate!.scrollViewWillBeginDragging!(scrollView)
			}
		}
	}

	public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)))) {
				self.actualDelegate!.scrollViewWillEndDragging!(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
			}
		}
	}

	public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)))) {
				self.actualDelegate!.scrollViewDidEndDragging!(scrollView, willDecelerate: decelerate)
			}
		}
		self.didTapOnTabView = false
	}

	public func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:)))) {
				return self.actualDelegate!.scrollViewShouldScrollToTop!(scrollView)
			}
		}
		return false
	}

	public func scrollViewDidScrollToTop(scrollView: UIScrollView) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:)))) {
				self.actualDelegate!.scrollViewDidScrollToTop!(scrollView)
			}
		}
	}

	public func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:)))) {
				self.actualDelegate!.scrollViewWillBeginDecelerating!(scrollView)
			}
		}
	}

	public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)))) {
				self.actualDelegate!.scrollViewDidEndDecelerating!(scrollView)
			}
		}
		self.didTapOnTabView = false
	}

  //MARK: Managing Zooming
	public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.viewForZoomingInScrollView(_:)))) {
				return self.actualDelegate!.viewForZoomingInScrollView!(scrollView)
			}
		}
		return nil
	}

	public func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewWillBeginZooming(_:withView:)))) {
				self.actualDelegate!.scrollViewWillBeginZooming!(scrollView, withView: view)
			}
		}
	}

	public func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidEndZooming(_:withView:atScale:)))) {
				self.actualDelegate!.scrollViewDidEndZooming!(scrollView, withView: view, atScale: scale)
			}
		}
	}

	public func scrollViewDidZoom(scrollView: UIScrollView) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidZoom(_:)))) {
				self.actualDelegate!.scrollViewDidZoom!(scrollView)
			}
		}
	}

  //UIScrollViewDelegate, Responding to Scrolling Animations
	public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
		if self.actualDelegate != nil {
			if (self.actualDelegate!.respondsToSelector(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)))) {
				self.actualDelegate!.scrollViewDidEndScrollingAnimation!(scrollView)
			}
		}
		self.didTapOnTabView = false
	}
}

//MARK: - TabView
class TabView: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.clearColor()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.backgroundColor = UIColor.clearColor()
	}
}

//MARK: - Extensions
extension Array {
	func find(includedElement: Element -> Bool) -> Int? {
		for (idx, element) in self.enumerate() {
			if includedElement(element) {
				return idx
			}
		}
		return 0
	}
}

