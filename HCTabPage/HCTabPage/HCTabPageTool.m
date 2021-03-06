//
//  HCTabPageTool.m
//  HCTabPage
//
//  Created by chc on 2017/12/27.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageTool.h"

@implementation HCTabPageTool
+ (UIViewController *)controllerForView:(UIView *)view
{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

+ (UIViewController *)vcHasNavcWithCurVc:(UIViewController *)curVc
{
    if (!curVc.navigationController) {
        if (!curVc.parentViewController) {
            return curVc;
        }
        else {
            return [self vcHasNavcWithCurVc:curVc.parentViewController];
        }
    }
    else {
        return curVc;
    }
}
@end
