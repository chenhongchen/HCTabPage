//
//  HCTabPageConst.h
//  HCTabPage
//
//  Created by chc on 2017/12/24.
//  Copyright © 2017年 CHC. All rights reserved.
//

UIKIT_EXTERN NSString *const TabPageScrollBar;
UIKIT_EXTERN NSString *const TabPageScrollSLJumpBar;
UIKIT_EXTERN NSString *const TabPageSegmBar;
UIKIT_EXTERN NSString *const TabPageSegmNaviBar;
UIKIT_EXTERN NSString *const TabPageEquantBar;

#define kTP_IOS11 ([[[UIDevice currentDevice]systemVersion] floatValue] >= 11.0)
#define kTP_Color(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kTP_AniDuration (0.333333)
#define kTp_MinAniDuration (0.233333)

#define kTP_ScreenH [UIScreen mainScreen].bounds.size.height
#define kTP_ScreenW [UIScreen mainScreen].bounds.size.width
