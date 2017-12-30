//
//  PageViewController.m
//  HCTabPage
//
//  Created by chc on 2017/12/22.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "PageViewController.h"

@interface PageViewController ()
@property (nonatomic, weak) UILabel *label;
@end

@implementation PageViewController

#pragma mark - 懒加载
- (UILabel *)label
{
    if (_label == nil) {
        UILabel *label = [[UILabel alloc] init];
        [self.view addSubview:label];
        _label = label;
        label.textColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.label.text = self.text;
    self.view.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
//    NSLog(@"%p", self);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSLog(@"viewWillAppear - %@", self.text);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    NSLog(@"viewDidAppear - %@", self.text);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSLog(@"viewWillDisappear - %@", self.text);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    NSLog(@"viewDidDisappear - %@", self.text);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.label.frame = self.view.bounds;
}

@end
