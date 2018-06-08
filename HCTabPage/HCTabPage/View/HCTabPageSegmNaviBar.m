//
//  HCTabPageSegmNaviBar.m
//  HCTabPage
//
//  Created by chc on 2017/12/27.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageSegmNaviBar.h"

@implementation HCTabPageSegmNaviBar
- (void)tablePageViewLayoutSubviews
{
    UIViewController *vc = [HCTabPageTool vcHasNavcWithCurVc:self.tablePageViewVc];
    vc.navigationItem.titleView = self.segment;
    [self.segment sizeToFit];
}
@end
