//
//  KHTabPagerViewController.h
//  KHTabPagerViewControllerExample
//
//  Created by Kareem Hewady on 9/3/15.
//  Copyright (c) 2015 K H. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KHTabPagerDataSource;
@protocol KHTabPagerDelegate;

@interface KHTabPagerViewController : UIViewController

@property (weak, nonatomic) id<KHTabPagerDataSource> dataSource;
@property (weak, nonatomic) id<KHTabPagerDelegate> delegate;

- (void)reloadData;
- (NSInteger)selectedIndex;

- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation;

@end

@protocol KHTabPagerDataSource <NSObject>

@required
- (NSInteger)numberOfViewControllers;
- (UIViewController *)viewControllerForIndex:(NSInteger)index;

@optional
- (UIView *)viewForTabAtIndex:(NSInteger)index;
- (NSString *)titleForTabAtIndex:(NSInteger)index;
- (CGFloat)tabHeight;
- (UIColor *)tabColor;
- (UIColor *)tabBackgroundColor;
- (UIFont *)titleFont;
- (UIColor *)titleColor;
- (CGFloat)tabBarTopViewHeight;
- (UIView *)tabBarTopView;
- (BOOL)isProgressiveTabBar;

@end

@protocol KHTabPagerDelegate <NSObject>

@optional
- (void)tabPager:(KHTabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index;
- (void)tabPager:(KHTabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index;

@end