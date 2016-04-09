# KHTabPagerViewController

[![CocoaPods](https://img.shields.io/cocoapods/v/KHTabPagerViewController.svg)](http://cocoadocs.org/docsets/KHTabPagerViewController) [![CocoaPods](https://img.shields.io/cocoapods/l/KHTabPagerViewController.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/p/KHTabPagerViewController.svg)]()


<img src="gifs/demo.gif" alt="Animated gif">

## Introduction
This is a slightly tweaked implementation for the tab pager view controller. It's heavily based on [guilhermearaujo/GUITabPagerViewController](https://github.com/guilhermearaujo/GUITabPagerViewController)

**Added Features**

1. Support for progressive scrolling.
2. Support for a custom view to be drawn above the tab bar. This is particularly handy if you need to present more controls based upon the child view controllers. 
3. **Now with full RTL UI mirroring support (for Arabic localization) for both iOS 9 new APIs and the older iOS 8 and earlier.**

## Progressive Scrolling
This is a side-by-side comparison between the progressive and non-progressive scrolling behavior.

**Progressive** (on the left) tracks the touch movement to update the tab bar accordingly.

**Non-progressive** (on the right) snaps to the next tab once the touch starts moving.

<img src="gifs/progressive.gif" alt="Animated gif">

## Installation
**CocoaPods** (recommended)  
Add the following line to your `Podfile`:  
`pod 'KHTabPagerViewController', '~> 1.0.0'`  
And then add `#import <KHTabPagerViewController.h>` to your view controller.

**Manual**  
Copy the folder `KHTabPagerViewController` to your project, then add `#import "KHTabPagerViewController.h"` to your view controller.

## Usage
To use it, you should create a view controller that extends `KHTabPagerViewController`. Write your `viewDidLoad` as follows:

```obj-c
- (void)viewDidLoad {
  [super viewDidLoad];
  [self setDataSource:self];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadData]; 
  }
```

Then, implement the `KHTabPagerDataSource` to populate the view.
The data source has a couple of required methods, and a few more optional.

### Data Source
The data source methods will allow you to provide content to your tab pager view controller.

#### Required Methods
```obj-c
- (NSInteger)numberOfViewControllers;
- (UIViewController *)viewControllerForIndex:(NSInteger)index;
```

#### Optional Methods
**Note that despite being optional, the tab setup will require you to return either a `UIView` or an `NSString` to work.**

```obj-c
- (UIView *)viewForTabAtIndex:(NSInteger)index;
- (NSString *)titleForTabAtIndex:(NSInteger)index;
- (CGFloat)tabHeight;  // Default value: 44.0f
- (UIColor *)tabColor; // Default value: [UIColor orangeColor]
- (UIColor *)tabBackgroundColor; // Default: [UIColor colorWithWhite:0.95f alpha:1.0f];
- (UIFont *)titleFont; // Default: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
- (UIColor *)titleColor; // Default: [UIColor blackColor];
- (CGFloat)tabBarTopViewHeight; //Default value: 0.0f
- (UIView *)tabBarTopView;  //Default: nil
- (BOOL)isProgressiveTabBar; //Default value: YES
```

### Delegate
The delegate methods report events that happened in the tab pager view controller.

#### Optional Methods
```obj-c
- (void)tabPager:(GUITabPagerViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index;
- (void)tabPager:(GUITabPagerViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index;
```

### Public Methods

```obj-c
- (void)reloadData;
- (NSInteger)selectedIndex;
- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation;
```

`reloadData` will refresh the content of the tab pager view controller. Make sure to provide the data source before reloading the content.

`selectedIndex` will return the index of the current selected tab.

`selectTabbarIndex:animation:` will change to selected view controller programatically
