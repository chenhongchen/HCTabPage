//
//  HCTabPageEquantBar.m
//  HCTabPage
//
//  Created by chc on 2018/3/16.
//  Copyright © 2018年 CHC. All rights reserved.
//

#import "HCTabPageEquantBar.h"

@interface HCTabPageEquantBar ()
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) NSInteger selIndex;
@property (nonatomic, assign) NSInteger lastIndex;

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *vLines;
@property (nonatomic, weak) UIView *slideLine;
@property (nonatomic, weak) UIView *botLine;

@end

@implementation HCTabPageEquantBar
#pragma mark - 懒加载
- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UIView *)slideLine
{
    if (_slideLine == nil) {
        UIView *slideLine = [[UIView alloc] init];
        [self.contentView addSubview:slideLine];
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

#pragma mark - 外部方法
- (void)setTitles:(NSArray<NSString *> *)titles
{
    [self clearItems];
    _titles = titles;
    NSMutableArray *arrayM = [NSMutableArray array];
    NSMutableArray *vLinesM = [NSMutableArray array];
    for (int i = 0; i < titles.count; i ++) {
        NSString *title = titles[i];
        UIButton *item = [[UIButton alloc] init];
        item.titleLabel.font = _titleFont;
        [item setTitleColor:_titleColor forState:UIControlStateNormal];
        [item setTitle:title forState:UIControlStateNormal];
        [self.contentView addSubview:item];
        [arrayM addObject:item];
        item.tag = i;
        [item addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i > 0) {
            UIView *vLine = [[UIView alloc] init];
            vLine.backgroundColor = _vLineColor;
            [self.contentView addSubview:vLine];
            [vLinesM addObject:vLine];
        }
    }
    _items = arrayM;
    _vLines = vLinesM;
    [self setupBtnsFrameWithAnimation:NO];
}

- (void)setOffsetX:(CGFloat)offsetX animaton:(BOOL)animation
{
    _offsetX = offsetX;
    NSArray *positions = [self positionsForPageOffsetX:_offsetX];
    [self setupItemsWithPositions:positions animation:animation];
    [self setupSlideLineFrameWithPositions:positions animation:animation];
    self.slideLine.hidden = NO;
}

- (void)selectTabAtIndex:(NSInteger)selIndex animation:(BOOL)animation
{
    _offsetX = selIndex * self.superview.bounds.size.width;
    [self setOffsetX:_offsetX animaton:animation];
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
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

- (void)setVLineSize:(CGSize)vLineSize
{
    _vLineSize = vLineSize;
    [self setupVLinesFrame];
}

- (void)setVLineColor:(UIColor *)vLineColor
{
    _vLineColor = vLineColor;
    for (UIView *vLine in _vLines) {
        vLine.backgroundColor = _vLineColor;
    }
}

#pragma mark - 初始化
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupOtherViewsFrame];
    [self setupBtnsFrameWithAnimation:NO];
    [self setupItemsWithPositions:[self positionsForPageOffsetX:_offsetX]  animation:NO];
    [self setupSlideLineFrameWithPositions:[self positionsForPageOffsetX:_offsetX] animation:NO];
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
        self.contentView.frame = CGRectMake(0, 0, selfWidth, selfHeight - _botLineHeight);
    }
    else {
        CGFloat h = selfHeight - _botLineHeight;
        CGFloat centerX = h * 0.5;
        CGFloat y = ceil(centerX - _btnHeight * 0.5);
        self.contentView.frame = CGRectMake(0, y, selfWidth, _btnHeight);
    }
    self.botLine.frame = CGRectMake(0, self.bounds.size.height - _botLineHeight, self.bounds.size.width, _botLineHeight);
}

- (void)setupBtnsFrameWithAnimation:(BOOL)animation
{
    CGFloat width = self.contentView.bounds.size.width / _items.count;
    CGFloat height = self.contentView.bounds.size.height;
    CGFloat y = 0;
    for (int i = 0; i < _items.count; i ++) {
        UIButton *item = _items[i];
        item.transform = CGAffineTransformIdentity;
        CGFloat x = i * width;
        item.frame = CGRectMake(x, y, width, height);
    }
    
    [self setupVLinesFrame];
}

- (void)setupVLinesFrame
{
    CGFloat width = self.contentView.bounds.size.width / _items.count;
    CGFloat height = self.contentView.bounds.size.height;
    for (int i = 0; i < _vLines.count; i ++) {
        CGFloat x = (i + 1) * width - _vLineSize.width * 0.5;
        CGFloat y = (height - _vLineSize.height) * 0.5;
        UIView *vLine = _vLines[i];
        vLine.frame = CGRectMake(x, y, _vLineSize.width, _vLineSize.height);
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
        if ((_selIndex != selIndex || _selIndex == _lastIndex) && lRatio == 0) {
            _lastIndex = _selIndex;
            UIButton *lastItem = _items[_lastIndex];
            lastItem.titleLabel.font = _titleFont;
            _selIndex = selIndex;
            UIButton *selItem = _items[_selIndex];
            selItem.titleLabel.font = _selTitleFont;
            if (!_gradientTitleColor) {
                [lastItem setTitleColor:_titleColor forState:UIControlStateNormal];
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
                [lastItem setTitleColor:_titleColor forState:UIControlStateNormal];
                [selItem setTitleColor:_selTitleColor forState:UIControlStateNormal];
            }
            // 设置selItem字体
            NSString *fontUIUsageAttribute = _selTitleFont.fontDescriptor.fontAttributes[@"NSCTFontUIUsageAttribute"];
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
    
    CGSize size = [leftItem sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat leftItemW = size.width;
    CGFloat leftItemCX = (leftIndex * leftItem.bounds.size.width) + leftItem.bounds.size.width * 0.5;
    size = [rightItem sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat rightItemW = size.width;
    CGFloat rightItemCX = (rightIndex * rightItem.bounds.size.width) + leftItem.bounds.size.width * 0.5;
    CGFloat lToRHorDistance = rightItemCX - leftItemCX;
    CGFloat differenceW = rightItemW - leftItemW;
    
    CGFloat slideLineCX = leftItemCX + lToRHorDistance * lRatio;
    CGFloat slideLineW = leftItemW + differenceW * lRatio;
    
    CGRect rect = self.slideLine.frame;
    rect.origin.y = self.contentView.bounds.size.height - rect.size.height;
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

#pragma mark - 事件
- (void)itemClicked:(UIButton *)item
{
    if ([self.delegate respondsToSelector:@selector(tabPageBar:didSelectItemAtIndex:fromIndex: animation:)]) {
        [self.delegate tabPageBar:self didSelectItemAtIndex:item.tag fromIndex:_selIndex animation:YES];
    }
    [self selectTabAtIndex:item.tag animation:YES];
    _selIndex = item.tag;
}
@end
