//
//  HCTabPageEquantNavBar.m
//  HCTabPage
//
//  Created by chc on 2018/4/11.
//  Copyright © 2018年 CHC. All rights reserved.
//

#import "HCTabPageEquantNavBar.h"

@implementation HCTabPageEquantNavBar
- (void)layoutSubviews
{
    [super layoutSubviews];
    [HCTabPageTool controllerForView:self].navigationItem.titleView = self;
    CGRect rect = self.frame;
    rect.size = self.navBarSzie;
    self.frame = rect;
    self.alpha = 0.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTP_IOS11 ? 0 : kTP_AniDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kTP_AniDuration animations:^{
            self.alpha = 1.0;
        }];
    });
}
@end
