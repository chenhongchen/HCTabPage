//
//  HCTabPageJumpEquantNavBar.m
//  HCTabPage
//
//  Created by chc on 2019/3/12.
//  Copyright © 2019 CHC. All rights reserved.
//

#import "HCTabPageJumpEquantNavBar.h"

@implementation HCTabPageJumpEquantNavBar
- (void)tablePageViewLayoutSubviews
{
    CGRect rect = CGRectMake(0, 0, self.navBarSzie.width, self.navBarSzie.height);
    rect.origin.x = (kTP_ScreenW - rect.size.width) * 0.5;
    rect.origin.y = 0;
    self.frame = rect;
    if (self.navItem) {
        self.navItem.titleView = self;
    }
    else
    {
        UIViewController *vc = [HCTabPageTool vcHasNavcWithCurVc:self.tablePageViewVc];
        vc.navigationItem.titleView = self;
    }
}
@end
