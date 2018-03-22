//
//  HCTPScrollView.m
//  HCTabPage
//
//  Created by chc on 2018/3/22.
//  Copyright © 2018年 CHC. All rights reserved.
//

#import "HCTPScrollView.h"
#import "HCTabPageConst.h"

@implementation HCTPScrollView

#pragma mark - 重写系统方法
//一句话总结就是此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应。
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([self panBack:gestureRecognizer]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    return YES;
}

#pragma mark - 外部方法
- (void)setForbitLeftScrollWidthRatio:(CGFloat)forbitLeftScrollWidthRatio
{
    _forbitLeftScrollWidthRatio = forbitLeftScrollWidthRatio;
    if (_forbitLeftScrollWidthRatio < 0) {
        _forbitLeftScrollWidthRatio = 0;
    }
    if (_forbitLeftScrollWidthRatio > 1) {
        _forbitLeftScrollWidthRatio = 1;
    }
}

- (void)setForbitLeftScrollPage:(NSInteger)forbitLeftScrollPage
{
    _forbitLeftScrollPage = forbitLeftScrollPage;
    if (_forbitLeftScrollPage < 0) {
        _forbitLeftScrollPage = 0;
    }
}

#pragma mark - 内部方法
//location_X可自己定义,其代表的是滑动返回距左边的有效长度
- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    
    //是滑动返回距左边的有效长度
    int location_X = _forbitLeftScrollWidthRatio * kTP_ScreenW;
    
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state ||UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:self];
            
            //下面的是只允许在第_forbitLeftScrollPage页时滑动返回生效
            if (point.x > 0 && location.x < location_X && self.contentOffset.x <= _forbitLeftScrollPage * kTP_ScreenW) {
                return YES;
            }
        }
    }
    return NO;
}

@end
