//
//  HCTabPageSegmNaviBar.m
//  HCTabPage
//
//  Created by chc on 2017/12/27.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageSegmNaviBar.h"

@implementation HCTabPageSegmNaviBar
- (void)layoutSubviews
{
    [super layoutSubviews];
    [HCTabPageTool controllerForView:self].navigationItem.titleView = self.segment;
    [self.segment sizeToFit];
    self.segment.alpha = 0.0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTP_IOS11 ? 0 : kTP_AniDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kTP_AniDuration animations:^{
            self.segment.alpha = 1.0;
        }];
    });
}
@end
