//
//  KHTabPagerViewController.m
//  KHTabPagerViewControllerExample
//
//  Created by Kareem Hewady on 9/3/15.
//  Copyright (c) 2015 K H. All rights reserved.
//


#import "KHTabPagerViewController.h"
#import "KHTabScrollView.h"

@interface KHTabPagerViewController () <KHTabScrollDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>
{
    BOOL tapped;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIScrollView *pageScrollView;
@property (strong, nonatomic) KHTabScrollView *header;
@property (assign, nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) NSMutableArray *tabTitles;
@property (strong, nonatomic) UIColor *headerColor;
@property (strong, nonatomic) UIColor *tabBackgroundColor;
@property (assign, nonatomic) CGFloat headerHeight;
@property (assign, nonatomic) BOOL isProgressive;
@property (assign, nonatomic) BOOL isTransitionInProgress;
@property (assign, nonatomic) CGFloat headerPadding;
@property (strong, nonatomic) UIView *headerTopView;

@end

@implementation KHTabPagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                              options:nil]];
    
    for (UIView *view in [[[self pageViewController] view] subviews]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView = (UIScrollView *)view;
            [self.pageScrollView setCanCancelContentTouches:YES];
            [self.pageScrollView setDelaysContentTouches:NO];
            [self.pageScrollView setDelegate:self];
        }
    }
    
    tapped = false;
    
    [[self pageViewController] setDataSource:self];
    [[self pageViewController] setDelegate:self];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self reloadTabs];
    [self selectTabbarIndex:self.selectedIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    if (([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending) && [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        return pageIndex < [[self viewControllers] count] - 1 ? [self viewControllers][pageIndex + 1]: nil;
    } else return pageIndex > 0 ? [self viewControllers][pageIndex - 1]: nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    if (([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending) && [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        return pageIndex > 0 ? [self viewControllers][pageIndex - 1]: nil;
    } else return pageIndex < [[self viewControllers] count] - 1 ? [self viewControllers][pageIndex + 1]: nil;
}

#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    self.isTransitionInProgress = YES;
    if (!self.isProgressive) {
        NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
        [[self header] animateToTabAtIndex:index];
        
        if ([[self delegate] respondsToSelector:@selector(tabPager:willTransitionToTabAtIndex:)]) {
            [[self delegate] tabPager:self willTransitionToTabAtIndex:index];
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    [self setSelectedIndex:[[self viewControllers] indexOfObject:[[self pageViewController] viewControllers][0]]];
    [[self header] animateToTabAtIndex:[self selectedIndex]];
    self.isTransitionInProgress = NO;
    
    if ([[self delegate] respondsToSelector:@selector(tabPager:didTransitionToTabAtIndex:)]) {
        [[self delegate] tabPager:self didTransitionToTabAtIndex:[self selectedIndex]];
    }
}

- (void)reloadData {
    [self setViewControllers:[NSMutableArray array]];
    [self setTabTitles:[NSMutableArray array]];
    
    for (int i = 0; i < [[self dataSource] numberOfViewControllers]; i++) {
        UIViewController *viewController;
        
        if ((viewController = [[self dataSource] viewControllerForIndex:i]) != nil) {
            [[self viewControllers] addObject:viewController];
        }
        
        if ([[self dataSource] respondsToSelector:@selector(titleForTabAtIndex:)]) {
            NSString *title;
            if ((title = [[self dataSource] titleForTabAtIndex:i]) != nil) {
                [[self tabTitles] addObject:title];
            }
        }
    }
    
    [self reloadTabs];
    
    CGRect frame = [[self view] frame];
    frame.origin.y = [self headerHeight] + [self headerPadding];
    frame.size.height -= [self headerHeight] + [self headerPadding];
    
    [[[self pageViewController] view] setFrame:frame];
    
    [self.pageViewController setViewControllers:@[[self viewControllers][0]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:NO
                                     completion:nil];
    [self setSelectedIndex:0];
}

- (void)reloadTabs {
    if ([[self dataSource] numberOfViewControllers] == 0)
        return;
    
    if ([[self dataSource] respondsToSelector:@selector(tabHeight)]) {
        [self setHeaderHeight:[[self dataSource] tabHeight]];
    } else {
        [self setHeaderHeight:44.0f];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabColor)]) {
        [self setHeaderColor:[[self dataSource] tabColor]];
    } else {
        [self setHeaderColor:[UIColor orangeColor]];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabBackgroundColor)]) {
        [self setTabBackgroundColor:[[self dataSource] tabBackgroundColor]];
    } else {
        [self setTabBackgroundColor:[UIColor colorWithWhite:0.95f alpha:1.0f]];
    }
    if ([[self dataSource] respondsToSelector:@selector(isProgressiveTabBar)]) {
        [self setIsProgressive:[[self dataSource] isProgressiveTabBar]];
    } else {
        [self setIsProgressive:YES];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabBarTopViewHeight)]) {
        [self setHeaderPadding:[[self dataSource] tabBarTopViewHeight]];
    } else {
        [self setHeaderPadding:0];
    }
    
    if ([[self dataSource] respondsToSelector:@selector(tabBarTopView)]) {
        UIView *view = [[self dataSource] tabBarTopView];
        view.tag = 666; //Dirty way to remove the view later on. Please change
        [self setHeaderTopView:view];
    } else {
        [self setHeaderTopView:nil];
    }
    
    NSMutableArray *tabViews = [NSMutableArray array];
    
    if ([[self dataSource] respondsToSelector:@selector(viewForTabAtIndex:)]) {
        for (int i = 0; i < [[self viewControllers] count]; i++) {
            UIView *view;
            if ((view = [[self dataSource] viewForTabAtIndex:i]) != nil) {
                [tabViews addObject:view];
            }
        }
    } else {
        UIFont *font;
        if ([[self dataSource] respondsToSelector:@selector(titleFont)]) {
            font = [[self dataSource] titleFont];
        } else {
            font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0f];
        }
        
        UIColor *color;
        if ([[self dataSource] respondsToSelector:@selector(titleColor)]) {
            color = [[self dataSource] titleColor];
        } else {
            color = [UIColor blackColor];
        }
        
        for (NSString *title in [self tabTitles]) {
            UILabel *label = [UILabel new];
            [label setText:title];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:font];
            [label setTextColor:color];
            [label sizeToFit];
            
            CGRect frame = [label frame];
            frame.size.width = MAX(frame.size.width + 20, 85);
            [label setFrame:frame];
            [tabViews addObject:label];
        }
    }
    
    if ([self header]) {
        [[self header] removeFromSuperview];
    }
    
    if ([self headerTopView]) {
        for (UIView *view in self.view.subviews) {
            if (view.tag == 666) {
                [view removeFromSuperview];
            }
        }
    }
    
    CGRect frame = self.view.frame;
    frame.origin.y = [self headerPadding];
    frame.size.height = [self headerHeight];
    [self setHeader:[[KHTabScrollView alloc] initWithFrame:frame tabViews:tabViews tabBarHeight:[self headerHeight] tabBarTopViewHeight:[self headerPadding] tabColor:[self headerColor] backgroundColor:[self tabBackgroundColor] selectedTabIndex:self.selectedIndex]];
    [[self header] setTabScrollDelegate:self];
    
    [[self view] addSubview:[self header]];
    [[self view] addSubview:[self headerTopView]];
}

#pragma mark - Tab Scroll View Delegate

-(BOOL)shouldAllowTapOnScrollView:(KHTabScrollView *)tabScrollView {
    return (!self.isTransitionInProgress && !self.pageScrollView.isTracking && !self.pageScrollView.isDragging && !self.pageScrollView.isDecelerating);
}

- (void)tabScrollView:(KHTabScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index {
    if (index != [self selectedIndex] && !self.isTransitionInProgress) {
        self.pageScrollView.scrollEnabled = NO;
        if ([[self delegate] respondsToSelector:@selector(tabPager:willTransitionToTabAtIndex:)]) {
            [[self delegate] tabPager:self willTransitionToTabAtIndex:index];
        }
        tapped = true;
        UIPageViewControllerNavigationDirection direction;
        if ((([UIView respondsToSelector:@selector(userInterfaceLayoutDirectionForSemanticContentAttribute:)]) && ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.view.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft)) || ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft)) {
            direction = (index > [self selectedIndex]) ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
        } else {
            direction = (index > [self selectedIndex]) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
        }
        __weak typeof(self) weakSelf = self;
        [[self pageViewController]  setViewControllers:@[[self viewControllers][index]]
                                             direction:direction
                                              animated:YES
                                            completion:^(BOOL finished) {
                                                [weakSelf setSelectedIndex:index];
                                                if ([[weakSelf delegate] respondsToSelector:@selector(tabPager:didTransitionToTabAtIndex:)]) {
                                                    [[weakSelf delegate] tabPager:self didTransitionToTabAtIndex:[self selectedIndex]];
                                                }
                                                weakSelf.pageScrollView.scrollEnabled = YES;
                                            }];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self isProgressive]) {
        CGPoint offset = scrollView.contentOffset;
        float progress = 0;
        NSInteger fromIndex = self.selectedIndex;
        NSInteger toIndex = -1;
        progress = (offset.x - self.view.bounds.size.width) / self.view.bounds.size.width;
        if ((([UIView respondsToSelector:@selector(userInterfaceLayoutDirectionForSemanticContentAttribute:)]) && ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.view.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft)) || ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft)) {
            progress = -1 * progress;
        }
        if (progress > 0) {
            if (fromIndex < [[self viewControllers] count] - 1) {
                toIndex = fromIndex + 1;
            }
        }
        else {
            if (fromIndex > 0) {
                toIndex = fromIndex - 1;
            }
        }
        if (!tapped) {
            [[self header] animateFromTabAtIndex:fromIndex toTabAtIndex:toIndex withProgress:progress];
        }
        else if (fabs(progress) >= 0.999999 || fabs(progress) <= 0.000001)
            tapped = false;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isTransitionInProgress = YES;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isTransitionInProgress = NO;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.isTransitionInProgress = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isTransitionInProgress = NO;
}

#pragma mark - Public Methods

- (void)selectTabbarIndex:(NSInteger)index {
    [self selectTabbarIndex:index animation:NO];
}

- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation {
    [self.pageViewController setViewControllers:@[[self viewControllers][index]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:animation
                                     completion:nil];
    [[self header] animateToTabAtIndex:index animated:animation];
    [self setSelectedIndex:index];
}

@end