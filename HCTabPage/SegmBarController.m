//
//  SegmBarController.m
//  HCTabPage
//
//  Created by chc on 2017/12/28.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "SegmBarController.h"
#import "HCTabPage.h"
#import "PageTableViewController.h"

@interface SegmBarController ()<HCTabPageViewDataSource, HCTabPageViewDelegate>
@property (nonatomic, weak) HCTabPageView *tabPageView;
@end

@implementation SegmBarController
- (HCTabPageView *)tabPageView
{
    if (_tabPageView == nil) {
        HCTabPageView *tabPageView = [[HCTabPageView alloc] initWithBarStyle:TabPageSegmBar];
        [self.view addSubview:tabPageView];
        _tabPageView = tabPageView;
        tabPageView.dataSource = self;
        tabPageView.delegate = self;
        tabPageView.ownVC = self;
        tabPageView.titleFont = [UIFont systemFontOfSize:14];
        tabPageView.selTitleFont = [UIFont systemFontOfSize:14];
        tabPageView.selTitleColor = [UIColor purpleColor];
        tabPageView.slideLineColor = [UIColor purpleColor];
        tabPageView.tabPageBarHeight = 44;
        tabPageView.curIndex = 1;
        tabPageView.padding = 20;
        tabPageView.gradientTitleColor = YES;
        tabPageView.btnHeight = 30;
        
        CGRect rect = [UIScreen mainScreen].bounds;
        rect.origin.y = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.bounds.size.height;
        rect.size.height = rect.size.height - rect.origin.y - (self.navigationController.childViewControllers.count > 1 ? 0 : 49);
        tabPageView.frame = rect;
    }
    return _tabPageView;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNav];
    [self tabPageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.y = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.bounds.size.height;
    rect.size.height = rect.size.height - rect.origin.y - (self.navigationController.childViewControllers.count > 1 ? 0 : 49);
    self.tabPageView.frame = rect;
}

- (BOOL)hidesBottomBarWhenPushed
{
    return self.navigationController.childViewControllers.count - 1;
}

- (void)setupNav
{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换页" style:UIBarButtonItemStylePlain target:self action:@selector(barItemClicked)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
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
    pageVc.detineClass = [self class];
    return pageVc;
}

- (NSString *)tabPageView:(HCTabPageView *)tabPageView titleForTabBarAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:((index % 2) ? @"你现在第 %ld 页" : @"第 %ld 页"), (long)index];
}

#pragma mark - HCTabPageViewDelegate
- (void)tabPageView:(HCTabPageView *)tabPageView didSelectTabBarAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex
{
//    NSLog(@"didSelectTabBarAtIndex: %ld fromIndex: %ld", atIndex, fromIndex);
}

- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex formIndex:(NSInteger)formIndex
{
//    NSLog(@"didChangePageToIndex: %ld fromIndex: %ld", toIndex, formIndex);
}

#pragma mark - 事件
- (void)barItemClicked
{
    [self.tabPageView setPageAtIndex:6 animation:YES];
}
@end
