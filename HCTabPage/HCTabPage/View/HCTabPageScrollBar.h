//
//  HCTabPageScrollBar.h
//  HCTabPage
//
//  Created by chc on 2017/12/27.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageBar.h"

@interface HCTabPageScrollBar : HCTabPageBar
{
    NSArray *_items;
    __weak UIView *_slideLine;
    __weak UIScrollView *_scrollView;
}
@end
