//
//  HCTabPageScrollBar.m
//  HCTabPage
//
//  Created by chc on 2017/12/27.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageScrollBar.h"

@interface HCTabPageScrollBar ()<UIScrollViewDelegate>
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) NSInteger selIndex;
@property (nonatomic, assign) NSInteger lastIndex;

@property (nonatomic, weak) UIView *topLine; // 用于防止scrollView自动布局
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) UIView *slideLine;
@property (nonatomic, weak) UIView *botLine;
@end

@implementation HCTabPageScrollBar
#pragma mark - 懒加载
- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        [self addSubview:scrollView];
        _scrollView = scrollView;
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)slideLine
{
    if (_slideLine == nil) {
        UIView *slideLine = [[UIView alloc] init];
        [self.scrollView addSubview:slideLine];
        _slideLine = slideLine;
        slideLine.hidden = YES;
    }
    return _slideLine;
}

- (UIView *)topLine
{
    if (_topLine == nil) {
        UIView *topLine = [[UIView alloc] init];
        [self addSubview:topLine];
        _topLine = topLine;
    }
    return _topLine;
}

- (UIView *)botLine
{
    if (_botLine == nil) {
        UIView *botLine = [[UIView alloc] init];
        [self addSubview:botLine];
        _botLine = botLine;
    }
    return _botLine;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupOtherViewsFrame];
    [self setupBtnsFrameWithAnimation:NO];
    [self setupSlideLineFrameWithPositions:[self positionsForPageOffsetX:_offsetX] animation:NO];
    [self scrollToFitForSelItemWithPositions:[self positionsForPageOffsetX:_offsetX] animation:NO];
}

#pragma mark - 外部方法
- (void)setTitles:(NSArray<NSString *> *)titles
{
    [self clearItems];
    _titles = titles;
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < titles.count; i ++) {
        NSString *title = titles[i];
        UIButton *item = [[UIButton alloc] init];
        item.titleLabel.font = _titleFont;
        [item setTitleColor:_titleColor forState:UIControlStateNormal];
        [item setTitle:title forState:UIControlStateNormal];
        [self.scrollView addSubview:item];
        [arrayM addObject:item];
        item.tag = i;
        [item addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    _items = arrayM;
    [self setupBtnsFrameWithAnimation:NO];
}

- (void)setLeftMargin:(CGFloat)leftMargin
{
    _leftMargin = leftMargin;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, _leftMargin, 0, _rightMargin);
}

- (void)setRightMargin:(CGFloat)rightMargin
{
    _rightMargin = rightMargin;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, _leftMargin, 0, _rightMargin);
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
    self.topLine.backgroundColor = bgColor;
    self.scrollView.backgroundColor = bgColor;
}

- (void)setSlideLineColor:(UIColor *)slideLineColor
{
    _slideLineColor = slideLineColor;
    self.slideLine.backgroundColor = _slideLineColor;
}

- (void)setSlideLineHeight:(CGFloat)slideLineHeight
{
    _slideLineHeight = slideLineHeight;
    CGRect rect = self.slideLine.frame;
    rect.size.height = _slideLineHeight;
    self.slideLine.frame = rect;
}

- (void)setBotLineColor:(UIColor *)botLineColor
{
    _botLineColor = botLineColor;
    self.botLine.backgroundColor = _botLineColor;
}

- (void)setBotLineHeight:(CGFloat)botLineHeight
{
    _botLineHeight = botLineHeight;
    CGRect rect = self.botLine.frame;
    rect.size.height = _botLineHeight;
    self.botLine.frame = rect;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    for (UIButton *item in _items) {
        item.titleLabel.font = titleFont;
    }
}

- (void)setSelTitleFont:(UIFont *)selTitleFont
{
    _selTitleFont = selTitleFont;
    UIButton *selItem = _items[_selIndex];
    selItem.titleLabel.font = _selTitleFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    for (UIButton *item in _items) {
        [item setTitleColor:titleColor forState:UIControlStateNormal];
    }
}

- (void)setSelTitleColor:(UIColor *)selTitleColor
{
    _selTitleColor = selTitleColor;
    UIButton *selItem = _items[_selIndex];
    [selItem setTitleColor:_selTitleColor forState:UIControlStateNormal];
}

- (void)setOffsetX:(CGFloat)offsetX animaton:(BOOL)animation
{
    _offsetX = offsetX;
    NSArray *positions = [self positionsForPageOffsetX:_offsetX];
    [self setupItemsWithPositions:positions animation:animation];
    [self setupSlideLineFrameWithPositions:positions animation:animation];
    [self scrollToFitForSelItemWithPositions:positions animation:animation];
    self.slideLine.hidden = NO;
}

- (void)selectTabAtIndex:(NSInteger)selIndex animation:(BOOL)animation
{
    _offsetX = selIndex * self.superview.bounds.size.width;
    [self setOffsetX:_offsetX animaton:animation];
}

#pragma mark - 内部方法
- (void)clearItems
{
    for (UIView *item in _items) {
        [item removeFromSuperview];
    }
    _items = nil;
}

- (void)setupOtherViewsFrame
{
    CGRect rect = self.bounds;
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat selfWidth = self.bounds.size.width;
    if (_btnHeight <= 0) {
        self.scrollView.frame = CGRectMake(0, 1, selfWidth, selfHeight - 1 - _botLineHeight);
    }
    else {
        CGFloat h = selfHeight - 1 - _botLineHeight;
        CGFloat centerX = 1 + h * 0.5;
        CGFloat y = centerX - _btnHeight * 0.5;
        self.scrollView.frame = CGRectMake(0, y, selfWidth, _btnHeight);
    }
    self.topLine.frame = CGRectMake(0, 0, rect.size.width, 1);
    self.botLine.frame = CGRectMake(0, self.bounds.size.height - _botLineHeight, self.bounds.size.width, _botLineHeight);
}

- (void)setupBtnsFrameWithAnimation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:kTP_AniDuration animations:^{
            UIButton *lastItem = nil;
            for (UIButton *item in _items) {
                //        item.backgroundColor = [UIColor greenColor];
                CGFloat x = lastItem ? CGRectGetMaxX(lastItem.frame) + _padding : 0;
                CGFloat y = 0;
                CGFloat height = self.scrollView.bounds.size.height;
                
                CGSize size = [item.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : item.titleLabel.font} context:nil].size;
                CGFloat width = size.width;
                item.frame = CGRectMake(x, y, width, height);
                lastItem = item;
            }
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastItem.frame), 0);
        }];
    }
    else {
        UIButton *lastItem = nil;
        for (UIButton *item in _items) {
            //        item.backgroundColor = [UIColor greenColor];
            CGFloat x = lastItem ? CGRectGetMaxX(lastItem.frame) + _padding : 0;
            CGFloat y = 0;
            CGFloat height = self.scrollView.bounds.size.height;
            
            CGSize size = [item.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : item.titleLabel.font} context:nil].size;
            CGFloat width = size.width;
            item.frame = CGRectMake(x, y, width, height);
            lastItem = item;
        }
        self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastItem.frame), 0);
    }
}

/** 设置items的frame，及其他属性 */
- (void)setupItemsWithPositions:(NSArray *)positions animation:(BOOL)animation
{
    NSInteger selIndex = [positions.firstObject integerValue];
    NSInteger leftIndex = [positions[1] integerValue];
    NSInteger rightIndex = [positions[2] integerValue];
    CGFloat lRatio = [positions.lastObject floatValue];
    UIButton *leftItem = _items[leftIndex];
    UIButton *rightItem = _items[rightIndex];
    CGFloat norR, norG, norB, norA;
    [_titleColor getRed:&norR green:&norG blue:&norB alpha:&norA];
    CGFloat selR, selG, selB, selA;
    [_selTitleColor getRed:&selR green:&selG blue:&selB alpha:&selA];
    
    // 设置lastItem、selItem字体，没有淡入淡出效果时字体颜色
    if (_selIndex != selIndex || _selIndex == _lastIndex) {
        _lastIndex = _selIndex;
        UIButton *lastItem = _items[_lastIndex];
        lastItem.titleLabel.font = _titleFont;
        _selIndex = selIndex;
        UIButton *selItem = _items[_selIndex];
        selItem.titleLabel.font = _selTitleFont;
        if (!_fadeTitleColor) {
            [lastItem setTitleColor:_titleColor forState:UIControlStateNormal];
            [selItem setTitleColor:_selTitleColor forState:UIControlStateNormal];
        }
        [self setupBtnsFrameWithAnimation:_hasBtnAnimation && animation];
    }
    
    if (!_fadeTitleColor) {
        return;
    }
    
    // 设置lastItem、selItem字体淡入淡出效果颜色
    if (lRatio == 0) {
        UIButton *lastItem = _items[_lastIndex];
        [lastItem setTitleColor:_titleColor forState:UIControlStateNormal];
        UIButton *selItem = _items[_selIndex];
        [selItem setTitleColor:_selTitleColor forState:UIControlStateNormal];
    }
    else
    {
        CGFloat dR = lRatio * (norR - selR);
        CGFloat dG = lRatio * (norG - selG);
        CGFloat dB = lRatio * (norB - selB);
        CGFloat dA = lRatio * (norA - selA);
        
        CGFloat R = selR + dR;
        CGFloat G = selG + dG;
        CGFloat B = selB + dB;
        CGFloat A = selA + dA;
        [leftItem setTitleColor:[UIColor colorWithRed:R green:G blue:B alpha:A] forState:UIControlStateNormal];
        R = selR + (norR - selR) - dR;
        G = selG + (norG - selG) - dG;
        B = selB + (norB - selB) - dB;
        A = selA + (norA - selA) - dA;
        [rightItem setTitleColor:[UIColor colorWithRed:R green:G blue:B alpha:A] forState:UIControlStateNormal];
    }
}

/** 根据page当前offsetX 设置 SlideLine 的frame */
- (void)setupSlideLineFrameWithPositions:(NSArray *)positions animation:(BOOL)animation
{
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
    CGFloat differenceW = rightItemW - leftItemW;
    
    CGFloat slideLineCX = leftItemCX + lToRHorDistance * lRatio;
    CGFloat slideLineW = leftItemW + differenceW * lRatio;
    
    CGRect rect = self.slideLine.frame;
    rect.origin.y = self.scrollView.bounds.size.height - rect.size.height;
    rect.size.width = slideLineW;
    if (animation) {
        [UIView animateWithDuration:kTp_MinAniDuration animations:^{
            self.slideLine.frame = rect;
            self.slideLine.center = CGPointMake(slideLineCX, self.slideLine.center.y);
        }];
    }
    else
    {
        self.slideLine.frame = rect;
        self.slideLine.center = CGPointMake(slideLineCX, self.slideLine.center.y);
    }
}

/** 移动选中的item到合适的位置 */
- (void)scrollToFitForSelItemWithPositions:(NSArray *)positions animation:(BOOL)animation
{
    NSInteger leftIndex = [positions[1] integerValue];
    NSInteger rightIndex = [positions[2] integerValue];
    if (!_realTimeMoveSelItem && leftIndex != rightIndex) {
        return;
    }
    NSInteger selIndex = [positions.firstObject integerValue];
    UIButton *selItem = _items[selIndex];
    CGFloat scrollViewContentW = self.scrollView.contentSize.width;
    CGFloat selItemCX = CGRectGetMinX(selItem.frame) + CGRectGetWidth(selItem.frame) * 0.5;
    CGFloat scrollViewW = self.scrollView.bounds.size.width;
    CGFloat scrollViewW_1_2 = scrollViewW * 0.5;
    if (animation) {
        [UIView animateWithDuration:kTP_AniDuration animations:^{
            if (selItemCX < scrollViewW_1_2) {
                self.scrollView.contentOffset = CGPointMake(-_leftMargin, 0);
            }
            else if (scrollViewContentW - selItemCX < scrollViewW_1_2) {
                self.scrollView.contentOffset = CGPointMake(scrollViewContentW - scrollViewW + _rightMargin, 0);
            }
            else {
                self.scrollView.contentOffset = CGPointMake(selItemCX - scrollViewW_1_2, 0);
            }
        }];
    }
    else
    {
        if (selItemCX < scrollViewW_1_2) {
            self.scrollView.contentOffset = CGPointMake(-_leftMargin, 0);
        }
        else if (scrollViewContentW - selItemCX < scrollViewW_1_2) {
            self.scrollView.contentOffset = CGPointMake(scrollViewContentW - scrollViewW + _rightMargin, 0);
        }
        else {
            self.scrollView.contentOffset = CGPointMake(selItemCX - scrollViewW_1_2, 0);
        }
    }
}

#pragma mark - 事件
- (void)itemClicked:(UIButton *)item
{
    UIButton *selItem = _items[_selIndex];
    if ([self.delegate respondsToSelector:@selector(tabPageBar:didSelectItemAtIndex:fromIndex:)]) {
        [self.delegate tabPageBar:self didSelectItemAtIndex:item.tag fromIndex:selItem.tag];
    }
    [self selectTabAtIndex:item.tag animation:YES];
}

- (void)timeEvent
{
    
}
@end
