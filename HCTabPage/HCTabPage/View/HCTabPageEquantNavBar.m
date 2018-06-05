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
    
    if (self.tablePageViewVc.isViewLoaded && self.tablePageViewVc.view.window) {
        CGRect rect = CGRectMake(0, 0, self.navBarSzie.width, self.navBarSzie.height);
        rect.origin.x = (kTP_ScreenW - rect.size.width) * 0.5;
        rect.origin.y = 0;
        
        if (!CGSizeEqualToSize(rect.size, self.tablePageViewVc.navigationItem.titleView.frame.size)) {
            self.frame = rect;
            self.tablePageViewVc.navigationItem.titleView = self;
            self.alpha = 0.0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTP_IOS11 ? 0 : kTP_AniDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:kTP_AniDuration animations:^{
                    self.alpha = 1.0;
                }];
            });
        }
    }
}
@end
