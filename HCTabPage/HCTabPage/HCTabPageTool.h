//
//  HCTabPageTool.h
//  HCTabPage
//
//  Created by chc on 2017/12/27.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCTabPageTool : NSObject
+ (UIViewController *)controllerForView:(UIView *)view;
+ (UIViewController *)vcHasNavcWithCurVc:(UIViewController *)curVc;
@end
