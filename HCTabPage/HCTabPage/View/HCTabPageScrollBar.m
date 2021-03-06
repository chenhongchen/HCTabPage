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
        scrollView.backgroundColor = [UIColor clearColor];
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

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupOtherViewsFrame];
    [self setupBtnsFrameWithAnimation:NO];
    [self setupItemsWithPositions:[self positionsForPageOffsetX:_offsetX]  animation:NO];
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
    if (_slideLineCap) {
        self.slideLine.layer.cornerRadius = self.slideLine.bounds.size.height * 0.5;
    }
}

- (void)setSlideLineCap:(BOOL)slideLineCap
{
    _slideLineCap = slideLineCap;
    if (_slideLineCap) {
        self.slideLine.layer.cornerRadius = self.slideLine.bounds.size.height * 0.5;
    }
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
    if (_selTitleFont.pointSize < _titleFont.pointSize) {
        self.selTitleFont = titleFont;
    }
}

- (void)setSelTitleFont:(UIFont *)selTitleFont
{
    _selTitleFont = selTitleFont;
    if (!_gradientTitleFont) {
        UIButton *selItem = _items[_selIndex];
        selItem.titleLabel.font = _selTitleFont;
    }
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
    _offsetX = selIndex * self.pageW;
    [self setOffsetX:_offsetX animaton:animation];
}

- (UIButton *)barBtnAtIndex:(NSInteger)index
{
    if (index >= _items.count) {
        return nil;
    }
    return _items[index];
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
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat selfWidth = self.bounds.size.width;
    if (_btnHeight <= 0) {
        self.scrollView.frame = CGRectMake(0, 0, selfWidth, selfHeight - _botLineHeight);
    }
    else {
        CGFloat h = selfHeight - _botLineHeight;
        CGFloat centerX = h * 0.5;
        CGFloat y = ceil(centerX - _btnHeight * 0.5);
        self.scrollView.frame = CGRectMake(0, y, selfWidth, _btnHeight);
    }
    self.botLine.frame = CGRectMake(0, self.bounds.size.height - _botLineHeight, self.bounds.size.width, _botLineHeight);
}

- (void)setupBtnsFrameWithAnimation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:kTP_AniDuration animations:^{
            UIButton *lastItem = nil;
            for (UIButton *item in _items) {
                item.transform = CGAffineTransformIdentity;
                //        item.backgroundColor = [UIColor greenColor];
                CGFloat x = ceil(lastItem ? CGRectGetMaxX(lastItem.frame) + _padding : 0);
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
            item.transform = CGAffineTransformIdentity;
            //        item.backgroundColor = [UIColor greenColor];
            CGFloat x = ceil(lastItem ? CGRectGetMaxX(lastItem.frame) + _padding : 0);
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

- (void)setupBtnsUnSelTitleColor
{
    for (UIButton *item in _items) {
        [item setTitleColor:_titleColor forState:UIControlStateNormal];
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
    
    // 设置lastItem、selItem字体，没有渐变效果时字体颜色
    if (!_gradientTitleFont) { // 没有渐变效果字体
        if (lRatio == 0) {
            _lastIndex = _selIndex;
            UIButton *lastItem = _items[_lastIndex];
            lastItem.titleLabel.font = _titleFont;
            _selIndex = selIndex;
            UIButton *selItem = _items[_selIndex];
            selItem.titleLabel.font = _selTitleFont;
            if (!_gradientTitleColor) {
//                [lastItem setTitleColor:_titleColor forState:UIControlStateNormal];
                [self setupBtnsUnSelTitleColor];
                [selItem setTitleColor:_selTitleColor forState:UIControlStateNormal];
            }
            [self setupBtnsFrameWithAnimation:_hasBtnAnimation && animation];
        }
    }
    else // 有渐变效果字体
    {
        CGFloat selF = _selTitleFont.pointSize;
        CGFloat norF = _titleFont.pointSize;
        CGFloat sF = selF - norF;
        if (lRatio == 0) {
            _lastIndex = _selIndex;
            UIButton *lastItem = _items[_lastIndex];
            lastItem.titleLabel.font = _titleFont;
            
            _selIndex = selIndex;
            UIButton *selItem = _items[_selIndex];
            if (!_gradientTitleColor) {
//                [lastItem setTitleColor:_titleColor forState:UIControlStateNormal];
                [self setupBtnsUnSelTitleColor];
                [selItem setTitleColor:_selTitleColor forState:UIControlStateNormal];
            }
            // 设置selItem字体
            NSString *fontUIUsageAttribute = _selTitleFont.fontDescriptor.fontAttributes[@"NSCTFontUIUsageAttribute"];
            if (fontUIUsageAttribute == nil) {
                fontUIUsageAttribute =  _selTitleFont.fontDescriptor.fontAttributes[@"NSFontNameAttribute"];
            }
            if ([fontUIUsageAttribute isEqualToString:@"CTFontEmphasizedUsage"]) {// 粗体的情况
                selItem.titleLabel.font = [UIFont boldSystemFontOfSize:_titleFont.pointSize];
            }
            else if ([fontUIUsageAttribute isEqualToString:@"CTFontRegularUsage"]) {// 常规的情况
                selItem.titleLabel.font = [UIFont systemFontOfSize:_titleFont.pointSize];
            }
            else if (fontUIUsageAttribute.length) {// 其他字体的情况
                selItem.titleLabel.font = [UIFont fontWithName:fontUIUsageAttribute size:_titleFont.pointSize];
                if (!selItem.titleLabel.font) {
                    selItem.titleLabel.font = _titleFont;
                }
            }
            
            [self setupBtnsFrameWithAnimation:NO];
            
            // 设置selItem字体放大
            lastItem.transform = CGAffineTransformIdentity;
            CGFloat r = (norF + sF) / norF;
            selItem.transform = CGAffineTransformMakeScale(r, r);
        }
        else
        {
            CGFloat lF = (1 - lRatio) * sF;
            CGFloat rF = lRatio * sF;
            CGFloat lr = (norF + lF) / norF;
            CGFloat rr = (norF + rF) / norF;
            
            leftItem.transform = CGAffineTransformMakeScale(lr, lr);
            rightItem.transform = CGAffineTransformMakeScale(rr, rr);
        }
    }
    
    if (!_gradientTitleColor) {
        return;
    }
    
    // 设置lastItem、selItem字体淡入淡出效果颜色
    if (lRatio == 0) {
//        UIButton *lastItem = _items[_lastIndex];
//        [lastItem setTitleColor:_titleColor forState:UIControlStateNormal];
        [self setupBtnsUnSelTitleColor];
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
    UIButton *lastItem = _items.lastObject;
    CGFloat maxX = CGRectGetMaxX(lastItem.frame) + _leftMargin + _rightMargin;
    if (animation) {
        [UIView animateWithDuration:kTP_AniDuration animations:^{
            if (selItemCX < scrollViewW_1_2 - _leftMargin || maxX < self.scrollView.bounds.size.width) {
                self.scrollView.contentOffset = CGPointMake(-_leftMargin, 0);
            }
            else if (scrollViewContentW - selItemCX < scrollViewW_1_2 - _rightMargin) {
                self.scrollView.contentOffset = CGPointMake(scrollViewContentW - scrollViewW + _rightMargin, 0);
            }
            else {
                self.scrollView.contentOffset = CGPointMake(selItemCX - scrollViewW_1_2, 0);
            }
        }];
    }
    else
    {
        if (selItemCX < scrollViewW_1_2 - _leftMargin  || maxX < self.scrollView.bounds.size.width) {
            self.scrollView.contentOffset = CGPointMake(-_leftMargin, 0);
        }
        else if (scrollViewContentW - selItemCX < scrollViewW_1_2 - _rightMargin) {
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
    if ([self.delegate respondsToSelector:@selector(tabPageBar:didSelectItemAtIndex:fromIndex:animation:)]) {
        [self.delegate tabPageBar:self didSelectItemAtIndex:item.tag fromIndex:selItem.tag animation:YES];
    }
    [self selectTabAtIndex:item.tag animation:YES];
}

- (void)timeEvent
{
    
}
@end
