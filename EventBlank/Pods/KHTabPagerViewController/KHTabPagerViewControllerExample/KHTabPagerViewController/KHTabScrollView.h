//
//  KHTabScrollView.h
//  KHTabPagerViewControllerExample
//
//  Created by Kareem Hewady on 9/3/15.
//  Copyright (c) 2015 K H. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KHTabScrollDelegate;

@interface KHTabScrollView : UIScrollView

@property (weak, nonatomic) id<KHTabScrollDelegate> tabScrollDelegate;

- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews tabBarHeight:(CGFloat)height tabBarTopViewHeight:(CGFloat)padding tabColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor selectedTabIndex:(NSInteger)index;
- (instancetype)initWithFrame:(CGRect)frame tabViews:(NSArray *)tabViews tabBarHeight:(CGFloat)height tabBarTopViewHeight:(CGFloat)padding tabColor:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

- (void)animateToTabAtIndex:(NSInteger)index;
- (void)animateToTabAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)animateFromTabAtIndex:(NSInteger)fromIndex toTabAtIndex:(NSInteger)toIndex withProgress:(float)progress;


@end

@protocol KHTabScrollDelegate <NSObject>

- (void)tabScrollView:(KHTabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index;

@end
