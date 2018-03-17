//
//  KTEquantBarController.m
//  HCTabPage
//
//  Created by chc on 2018/3/16.
//  Copyright © 2018年 CHC. All rights reserved.
//

#import "KTEquantBarController.h"
#import "HCTabPageView.h"
#import "HCTabPageConst.h"
#import "PageTableViewController.h"
#import "ScrollBarController.h"

@interface KTEquantBarController ()<HCTabPageViewDataSource, HCTabPageViewDelegate, PageTableViewControllerDelegate>
@property (nonatomic, weak) HCTabPageView *tabPageView;
@property (nonatomic, weak) UIImageView *bigImageView;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) CGFloat curOffSetY;
@end

@implementation KTEquantBarController
#pragma mark - 懒加载
- (HCTabPageView *)tabPageView
{
    if (_tabPageView == nil) {
        HCTabPageView *tabPageView = [[HCTabPageView alloc] initWithBarStyle:TabPageEquantBar];
        [self.view addSubview:tabPageView];
        _tabPageView = tabPageView;
        tabPageView.dataSource = self;
        tabPageView.delegate = self;
        tabPageView.ownVC = self;
        tabPageView.titleColor = kTP_Color(68, 68, 68, 1.0);
        tabPageView.titleFont = [UIFont systemFontOfSize:16];
        tabPageView.selTitleFont = [UIFont systemFontOfSize:16];
        tabPageView.selTitleColor = kTP_Color(68, 68, 68, 1.0);
        tabPageView.slideLineColor = kTP_Color(77, 166, 235, 1.0);
        tabPageView.slideLineHeight = 2;
        tabPageView.tabPageBarHeight = 44;
        tabPageView.curIndex = 2;
        tabPageView.padding = 20;
        tabPageView.gradientTitleColor = YES;
        tabPageView.gradientTitleFont = YES;
        tabPageView.btnHeight = 28;
        tabPageView.realTimeMoveSelItem = NO;
        tabPageView.bgColor = [UIColor colorWithRed:255/255.0 green:255/255.0  blue:255/255.0  alpha:0.98];
        tabPageView.barY = self.offsetY;
        tabPageView.botLineColor = kTP_Color(235, 235, 235, 1.0);
        tabPageView.botLineHeight = 1.0;
//        tabPageView.scrollEnabled = NO;
        
        CGRect rect = [UIScreen mainScreen].bounds;
        if (self.navigationController.childViewControllers.count <= 1) {
            rect.origin.y = 0;
            rect.size.height = rect.size.height - 49;
        }
        else
        {
            rect.origin.y = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.bounds.size.height;
            rect.size.height = rect.size.height - rect.origin.y;
        }
        tabPageView.frame = rect;
        [self.view bringSubviewToFront:self.bigImageView];
    }
    return _tabPageView;
}

- (UIImageView *)bigImageView
{
    if (_bigImageView == nil) {
        UIImageView *bigImageView = [[UIImageView alloc] init];
        [self.view addSubview:bigImageView];
        _bigImageView = bigImageView;
        bigImageView.backgroundColor = [UIColor redColor];
        
        bigImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.offsetY);
    }
    return _bigImageView;
}

- (CGFloat)offsetY
{
    if (_offsetY == 0) {
        _offsetY = floor([UIScreen mainScreen].bounds.size.width * 9 / 16 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44);
    }
    return _offsetY;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    [self tabPageView];
}

#pragma mark - HCTabPageViewDataSource
- (void)tabPageView:(HCTabPageView *)tabPageView loadDataError:(NSString *)error
{
    //    NSLog(@"loadDataError: = %@", error);
}

- (NSInteger)numberOfPagesInTabPageView:(HCTabPageView *)tabPageView
{
    return 3;
}

- (UIViewController *)tabPageView:(HCTabPageView *)tabPageView controllerForPageAtIndex:(NSInteger)index
{
    PageTableViewController *pageVc = [[PageTableViewController alloc] init];
    pageVc.text = [NSString stringWithFormat:@"%ld", (long)index];
    pageVc.detineClass = [ScrollBarController class];
    pageVc.offsetY = self.offsetY + 44;
    if (index == 0) {
        pageVc.delegate = self;
    }
    return pageVc;
}

- (NSString *)tabPageView:(HCTabPageView *)tabPageView titleForTabBarAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:((index % 2) ? @"你现在第 %ld 页" : @"第 %ld 页"), (long)index];
}

#pragma mark - HCTabPageViewDelegate
- (void)tabPageView:(HCTabPageView *)tabPageView didSelectTabBarAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"didSelectTabBarAtIndex: %ld fromIndex: %ld, curIndex: %ld", atIndex, fromIndex, self.tabPageView.curIndex);
}

- (void)tabPageView:(HCTabPageView *)tabPageView willChangePageToIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"willChangePageToIndex: %ld fromIndex: %ld, curIndex: %ld", toIndex, fromIndex, self.tabPageView.curIndex);
    if (fromIndex != toIndex) {
        PageTableViewController *fromVc = self.tabPageView.childControllers[fromIndex];
        fromVc.delegate = nil;
        PageTableViewController *toVc = self.tabPageView.childControllers[toIndex];
        [toVc setupOffsetY:_curOffSetY];
    }
}

- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"didChangePageToIndex: %ld fromIndex: %ld, curIndex: %ld", toIndex, fromIndex, self.tabPageView.curIndex);
    PageTableViewController *toVc = self.tabPageView.childControllers[toIndex];
    toVc.delegate = self;
    [toVc setupOffsetY:_curOffSetY];
}

#pragma mark - PageTableViewControllerDelegate
- (void)pageTableViewController:(PageTableViewController *)pageTableViewController didScrollForScrollView:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (_curOffSetY == offsetY) {
        return;
    }

    _curOffSetY = offsetY;
    CGFloat sy = ((self.offsetY + 44) + offsetY);
    
//    NSLog(@"offsetY = %f, sy = %f, min = %f", offsetY, sy, CGFLOAT_MIN);
    
    if (sy >= 0) {
        self.tabPageView.barY = self.offsetY - sy;
        CGRect rect = self.bigImageView.frame;
        rect.origin.y = - sy;
//        NSLog(@"barY = %f", self.tabPageView.barY);
        if (self.tabPageView.barY < CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44) {
            self.tabPageView.barY = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44;
        }
        if (rect.origin.y < -(self.offsetY - (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44))) {
            rect.origin.y = -(self.offsetY - (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44));
        }
        [self.tabPageView refreshFrame];
        self.bigImageView.frame = rect;
    }
    else
    {
        self.tabPageView.barY = self.offsetY;
        CGRect rect = self.bigImageView.frame;
        rect.origin.y = 0;
        [self.tabPageView refreshFrame];
        self.bigImageView.frame = rect;
    }
}

@end
