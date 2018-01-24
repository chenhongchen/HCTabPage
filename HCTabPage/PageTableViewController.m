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
    
    if (self.navigationController.childViewControllers.count <= 1 && [self.parentViewController isKindOfClass:[ScrollBarController class]]) {
        self.tableView.contentInset = UIEdgeInsetsMake(88 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), 0, 0, 0);
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.navigationController.childViewControllers.count <= 1 && [self.parentViewController isKindOfClass:[ScrollBarController class]]) {
        self.tableView.contentInset = UIEdgeInsetsMake(88 + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame), 0, 0, 0);
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
    ScrollBarController *vc = [[self.detineClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
