//
//  HCTabPageBar.m
//  HCTabPage
//
//  Created by chc on 2017/12/24.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageBar.h"

@interface HCTabPageBar ()
@end

@implementation HCTabPageBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.hasBtnAnimation = YES;
        self.titleFont = [UIFont systemFontOfSize:15];
        self.selTitleFont = [UIFont systemFontOfSize:17];
        self.titleColor = kTP_Color(55, 55, 55, 1);
        self.selTitleColor = [UIColor redColor];
        self.leftMargin = 15;
        self.rightMargin = 15;
        self.padding = 15;
        self.slideLineColor = [UIColor redColor];
        self.slideLineHeight = 2;
        self.botLineColor = kTP_Color(248, 248, 248, 1);
        self.botLineHeight = 1;
        self.realTimeMoveSelItem = YES;
        self.vLineSize = CGSizeMake(1, 21);
        self.vLineColor = kTP_Color(224, 224, 224, 1);
    }
    return self;
}

- (void)setOffsetX:(CGFloat)offsetX animaton:(BOOL)animation
{
}

- (void)selectTabAtIndex:(NSInteger)selIndex animation:(BOOL)animation
{
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    self.backgroundColor = _bgColor;
}

/** pageOffset转换成index */
- (NSArray *)positionsForPageOffsetX:(CGFloat)pageOffsetX
{
    CGFloat pageW = self.superview.bounds.size.width;
    if (pageW <= 0) {
        return nil;
    }
    NSInteger leftIndex = floor(pageOffsetX / pageW);
    NSInteger rightIndex = ceil(pageOffsetX / pageW);
    CGFloat lRatio = (pageOffsetX - leftIndex * pageW) / pageW;
    if (leftIndex < 0) {
        leftIndex = 0;
        lRatio = 0;
    }
    if (leftIndex > _titles.count - 1) {
        leftIndex = _titles.count - 1;
        lRatio = 0;
    }
    if (rightIndex < 0) {
        rightIndex = 0;
        lRatio = 0;
    }
    if (rightIndex > _titles.count - 1) {
        rightIndex = _titles.count - 1;
        lRatio = 0;
    }
    if (leftIndex > rightIndex) {
        leftIndex = rightIndex;
        lRatio = 0;
    }
    NSInteger selIndex = ((lRatio < 0.5) ? leftIndex : rightIndex);
    return @[@(selIndex), @(leftIndex), @(rightIndex), @(lRatio)];
}
@end
