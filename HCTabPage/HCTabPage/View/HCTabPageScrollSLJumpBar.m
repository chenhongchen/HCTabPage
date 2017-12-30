//
//  HCTabPageScrollSLJumpBar.m
//  HCTabPage
//
//  Created by chc on 2017/12/29.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageScrollSLJumpBar.h"

@implementation HCTabPageScrollSLJumpBar

- (void)setupSlideLineFrameWithPositions:(NSArray *)positions animation:(BOOL)animation
{
    NSInteger curIndex = [positions[0] integerValue];
    NSInteger leftIndex = [positions[1] integerValue];
    NSInteger rightIndex = [positions[2] integerValue];
    CGFloat lRatio = [positions.lastObject floatValue];
    
    UIButton *leftItem = _items[leftIndex];
    UIButton *rightItem = _items[rightIndex];
    
    CGFloat leftItemW = CGRectGetWidth(leftItem.frame);
    CGFloat leftItemCX = CGRectGetMinX(leftItem.frame) + leftItemW * 0.5;
    CGFloat rightItemW = CGRectGetWidth(rightItem.frame);
    CGFloat rightItemCX = CGRectGetMinX(rightItem.frame) + rightItemW * 0.5;
    CGFloat lToRHorDistance = rightItemCX - leftItemCX;
    
    CGFloat minW = 16;
    CGFloat hMinw = minW * 0.5;
    CGFloat minX = (leftItemCX) - hMinw;
    CGFloat maxX = (leftItemCX) + hMinw;
    if (lRatio == 0) {
    }
    else if (curIndex == leftIndex) {
        minX = (leftItemCX) - hMinw + minW * lRatio * 2;
        maxX = (leftItemCX) + hMinw + (lToRHorDistance - minW) * lRatio * 2;
    }
    else
    {
        minX = (rightItemCX) - hMinw - (lToRHorDistance - minW) * (1-lRatio) * 2;
        maxX = (rightItemCX) + hMinw - minW * (1 - lRatio) * 2;
    }
    CGRect rect = _slideLine.frame;
    rect.origin.y = _scrollView.bounds.size.height - rect.size.height;
    rect.size.width = maxX - minX;
    rect.origin.x = minX;
    
    if (animation) {
        [UIView animateWithDuration:kTp_MinAniDuration animations:^{
            _slideLine.frame = rect;
        }];
    }
    else {
        _slideLine.frame = rect;
    }
    
    NSLog(@"_slideLine = %@", _slideLine);
}

@end
