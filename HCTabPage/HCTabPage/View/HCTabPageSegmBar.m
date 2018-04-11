//
//  HCTabPageSegmBar.m
//  HCTabPage
//
//  Created by chc on 2017/12/27.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageSegmBar.h"

@interface HCTabPageSegmBar ()
@property (nonatomic, weak) UISegmentedControl *segment;
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) NSInteger selIndex;
@property (nonatomic, assign) NSInteger lastIndex;
@end

@implementation HCTabPageSegmBar
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
    self.segment.frame = CGRectMake(_leftMargin, (self.bounds.size.height - _btnHeight) * 0.5, self.bounds.size.width - _leftMargin - _rightMargin, _btnHeight);
}

#pragma mark - 懒加载
- (UISegmentedControl *)segment
{
    if (_segment == nil) {
        UISegmentedControl *segment = [[UISegmentedControl alloc] init];
        [self addSubview:segment];
        _segment = segment;
        [segment addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

#pragma mark - 外部方法
- (void)setTitles:(NSArray<NSString *> *)titles
{
    _titles = titles;
    [self.segment removeAllSegments];
    for (int i = 0; i < titles.count; i ++) {
        NSString *title = _titles[i];
        [self.segment insertSegmentWithTitle:title atIndex:i animated:NO];
    }
}

- (void)setOffsetX:(CGFloat)offsetX animaton:(BOOL)animation
{
    _offsetX = offsetX;
    NSArray *positions = [self positionsForPageOffsetX:_offsetX];
    self.segment.selectedSegmentIndex = [positions.firstObject integerValue];
}

- (void)selectTabAtIndex:(NSInteger)selIndex animation:(BOOL)animation
{
    _offsetX = selIndex * self.pageW;
    [self setOffsetX:_offsetX animaton:animation];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.segment.tintColor = _titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    NSDictionary *attributes = @{NSFontAttributeName : _titleFont};
    [self.segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

#pragma mark -  事件
- (void)segmentClicked:(UISegmentedControl *)segment
{
    _lastIndex = _selIndex;
    _selIndex = segment.selectedSegmentIndex;
    if ([self.delegate respondsToSelector:@selector(tabPageBar:didSelectItemAtIndex:fromIndex:animation:)]) {
        [self.delegate tabPageBar:self didSelectItemAtIndex:_selIndex fromIndex:_lastIndex animation:YES];
    }
}
@end
