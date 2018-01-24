//
//  ScrollBarController.m
//  HCTabPage
//
//  Created by chc on 2017/12/24.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "ScrollBarController.h"
#import "HCTabPage.h"
#import "PageTableViewController.h"

@interface ScrollBarController ()<HCTabPageViewDataSource, HCTabPageViewDelegate>
@property (nonatomic, weak) HCTabPageView *tabPageView;
@property (nonatomic, weak) UIView *tabPageHeaderView;
@property (nonatomic, weak) UISearchBar *searchBar;
@end

@implementation ScrollBarController
- (HCTabPageView *)tabPageView
{
    if (_tabPageView == nil) {
        HCTabPageView *tabPageView = [[HCTabPageView alloc] init];
        [self.view addSubview:tabPageView];
        _tabPageView = tabPageView;
        tabPageView.dataSource = self;
        tabPageView.delegate = self;
        tabPageView.ownVC = self;
        tabPageView.titleColor = kTP_Color(48, 48, 48, 1.0);
        tabPageView.titleFont = [UIFont systemFontOfSize:17];
        tabPageView.selTitleFont = [UIFont boldSystemFontOfSize:19];
        tabPageView.selTitleColor = kTP_Color(253, 112, 34, 1.0);
        tabPageView.slideLineColor = kTP_Color(253, 112, 34, 1.0);
        tabPageView.slideLineHeight = 3;
        tabPageView.tabPageBarHeight = 44;
        tabPageView.curIndex = 2;
        tabPageView.padding = 20;
        tabPageView.gradientTitleColor = YES;
        tabPageView.gradientTitleFont = YES;
        tabPageView.btnHeight = 36;
        tabPageView.realTimeMoveSelItem = NO;
        tabPageView.bgColor = [UIColor colorWithRed:255/255.0 green:255/255.0  blue:255/255.0  alpha:0.9];
        
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
    }
    return _tabPageView;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNav];
    [self tabPageView];
    [self setupTabPageHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.childViewControllers.count <= 1) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.tabPageView.passThrough = YES;
    }
    else
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.tabPageView.passThrough = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    if (self.navigationController.childViewControllers.count <= 1) {
        rect.origin.y = 0;
        rect.size.height = rect.size.height - 49;
        self.tabPageView.slideLineHeight = 0;
    }
    else
    {
        rect.origin.y = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.bounds.size.height;
        rect.size.height = rect.size.height - rect.origin.y;
    }
    self.tabPageView.frame = rect;
    rect = self.searchBar.frame;
    rect.size.width = self.view.bounds.size.width;
    self.searchBar.frame = rect;
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

- (void)setupTabPageHeaderView
{
    UIView *tabPageHeaderView = [[UIView alloc] init];
    self.tabPageView.tabPageHeaderView = tabPageHeaderView;
    _tabPageHeaderView = tabPageHeaderView;
    tabPageHeaderView.backgroundColor = [UIColor whiteColor];
    tabPageHeaderView.frame = CGRectMake(0, 0, 200, 44);
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    _searchBar = searchBar;
    searchBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
    [tabPageHeaderView addSubview:searchBar];
}

#pragma mark - HCTabPageViewDataSource
- (void)tabPageView:(HCTabPageView *)tabPageView loadDataError:(NSString *)error
{
//    NSLog(@"loadDataError: = %@", error);
}

- (NSInteger)numberOfPagesInTabPageView:(HCTabPageView *)tabPageView
{
    return 10;
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
    NSLog(@"didSelectTabBarAtIndex: %ld fromIndex: %ld", atIndex, fromIndex);
}

- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex formIndex:(NSInteger)formIndex
{
//    self.tabPageHeaderView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    NSLog(@"didChangePageToIndex: %ld fromIndex: %ld", toIndex, formIndex);
}

#pragma mark - 事件
- (void)barItemClicked
{
    [self.tabPageView setPageAtIndex:6 animation:YES];
}
@end
