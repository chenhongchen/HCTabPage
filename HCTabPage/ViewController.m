//
//  ViewController.m
//  HCTabPage
//
//  Created by chc on 2017/12/29.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "ViewController.h"
#import "HCTabPageView.h"
#import "PageViewController.h"

@interface ViewController ()<HCTabPageViewDataSource, HCTabPageViewDelegate>
@property (nonatomic, weak) HCTabPageView *tabPageView;
@end

@implementation ViewController

#pragma mark - 懒加载
- (HCTabPageView *)tabPageView
{
    if (_tabPageView == nil) {
        HCTabPageView *tabPageView = [[HCTabPageView alloc] init];
        [self.view addSubview:tabPageView];
        _tabPageView = tabPageView;
        tabPageView.dataSource = self;
        tabPageView.delegate = self;
        tabPageView.ownVC = self;
        
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
    
    [self tabPageView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    rect.origin.y = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navigationController.navigationBar.bounds.size.height;
    rect.size.height = rect.size.height - rect.origin.y - (self.navigationController.childViewControllers.count > 1 ? 0 : 49);
    self.tabPageView.frame = rect;
}

- (void)setupPageControllers
{
}

#pragma mark - HCTabPageViewDataSource
- (void)tabPageView:(HCTabPageView *)tabPageView loadDataError:(NSString *)error
{
//    NSLog(@"loadDataError: = %@", error);
}

- (NSInteger)numberOfPagesInTabPageView:(HCTabPageView *)tabPageView
{
    return 5;
}

- (UIViewController *)tabPageView:(HCTabPageView *)tabPageView controllerForPageAtIndex:(NSInteger)index
{
    PageViewController *pageVc = [[PageViewController alloc] init];
    pageVc.text = [NSString stringWithFormat:@"你现在第 %ld 页 %p", index, pageVc];
    return pageVc;
}

- (NSString *)tabPageView:(HCTabPageView *)tabPageView titleForTabBarAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"你现在第 %ld 页", index];
}

#pragma mark - HCTabPageViewDelegate
- (void)tabPageView:(HCTabPageView *)tabPageView didSelectTabBarAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex
{
    NSLog(@"didSelectTabBarAtIndex: %ld fromIndex: %ld", atIndex, fromIndex);
}

- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex formIndex:(NSInteger)formIndex
{
    NSLog(@"didChangePageToIndex: %ld fromIndex: %ld", toIndex, formIndex);
}

@end
