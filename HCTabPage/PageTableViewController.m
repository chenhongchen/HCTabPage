//
//  PageTableViewController.m
//  HCTabPage
//
//  Created by chc on 2017/12/24.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "PageTableViewController.h"
#import "ScrollBarController.h"

@interface PageTableViewController ()

@end

@implementation PageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.navigationController.childViewControllers.count <= 1) {
        if ([self.parentViewController isKindOfClass:[ScrollBarController class]]) {
            self.tableView.contentInset = UIEdgeInsetsMake(88 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), 0, 0, 0);
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }
        else if (_offsetY > 0) {
            self.tableView.contentInset = UIEdgeInsetsMake(_offsetY, 0, 0, 0);
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.navigationController.childViewControllers.count <= 1 && [self.parentViewController isKindOfClass:[ScrollBarController class]]) {
        self.tableView.contentInset = UIEdgeInsetsMake(88 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), 0, 0, 0);
    }
    if (_offsetY > 0) {
        self.tableView.contentInset = UIEdgeInsetsMake(_offsetY, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSLog(@"viewWillAppear - %@", self.text);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear - %@", self.text);
    if (_detineClass == [ScrollBarController class]) {
        self.tableView.contentOffset = CGPointMake(0, -(88 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)));
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSLog(@"viewWillDisappear - %@", self.text);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear - %@", self.text);
}

#pragma mark - 外部方法
- (void)setupOffsetY:(CGFloat)offsetY
{
    CGFloat topH = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 88;
    if (self.tableView.contentSize.height < self.tableView.bounds.size.height - topH) {
        self.tableView.contentSize = CGSizeMake(0, self.tableView.bounds.size.height - topH);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(CGFLOAT_MIN * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (offsetY >= -topH) {
            if (self.tableView.contentOffset.y < - topH) {
                [self.tableView setContentOffset:CGPointMake(0, -topH) animated:NO];
            }
        }
        else
        {
            [self.tableView setContentOffset:CGPointMake(0, offsetY) animated:NO];
        }
        [self scrollViewDidScroll:self.tableView];
    });
}

#pragma mark - tableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第 %@ 页，第 %ld 行 %p", _text, indexPath.row, self];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    ScrollBarController *vc = [[self.detineClass alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageTableViewController:didScrollForScrollView:)]) {
        [self.delegate pageTableViewController:self didScrollForScrollView:scrollView];
    }
}

@end
