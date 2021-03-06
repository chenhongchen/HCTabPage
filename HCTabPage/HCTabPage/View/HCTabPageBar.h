//
//  HCTabPageBar.h
//  HCTabPage
//
//  Created by chc on 2017/12/24.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCTabPageConst.h"
#import "HCTabPageTool.h"

@class HCTabPageBar;
@protocol HCTabPageBarDelegate <NSObject>
- (void)tabPageBar:(HCTabPageBar *)tabPageBar didSelectItemAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex animation:(BOOL)animation;
@end

@interface HCTabPageBar : UIView
{
    NSArray <NSString *> *_titles;
    CGFloat _btnHeight;
    CGSize _navBarSzie;
    BOOL _hasBtnAnimation;
    CGFloat _leftMargin;
    CGFloat _rightMargin;
    CGFloat _padding;
    UIFont *_titleFont;
    UIFont *_selTitleFont;
    UIColor *_titleColor;
    UIColor *_selTitleColor;
    UIColor *_bgColor;
    UIColor *_slideLineColor;
    CGFloat _slideLineHeight;
    CGFloat _slideLineWidth;
    BOOL _slideLineCap;
    UIColor *_botLineColor;
    CGFloat _botLineHeight;
    CGSize _vLineSize;
    UIColor *_vLineColor;
    BOOL _equalSlideLineWidth;
    
    BOOL _realTimeMoveSelItem;
    BOOL _gradientTitleColor;
    BOOL _gradientTitleFont;
    NSDictionary *_otherAttri;
}

@property (nonatomic, strong) NSArray <NSString *> *titles;
@property (nonatomic, weak) id <HCTabPageBarDelegate> delegate;

/** 获取barBtn */
- (UIButton *)barBtnAtIndex:(NSInteger)index;

/** 根据page的当前的offsetX 设置slideLine、selItem */
- (void)setOffsetX:(CGFloat)offsetX animaton:(BOOL)animation;
/** 根据选中的索引 设置slideLine、selItem */
- (void)selectTabAtIndex:(NSInteger)selIndex animation:(BOOL)animation;
/** pageOffsetX转换成index */
- (NSArray *)positionsForPageOffsetX:(CGFloat)pageOffsetX;
/** tapPageView的宽 */
@property (nonatomic, assign, readonly) CGFloat pageW;

/** 为0则和bar一样高 */
@property (nonatomic, assign) CGFloat btnHeight;
@property (nonatomic, assign) CGSize navBarSzie;
@property (nonatomic, weak) UINavigationItem *navItem;
/** 滚动时 btn 的 frame变化是否有动画效果 */
@property (nonatomic, assign) BOOL hasBtnAnimation;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *selTitleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selTitleColor;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *slideLineColor;
@property (nonatomic, assign) CGFloat slideLineHeight;
@property (nonatomic, assign) BOOL slideLineCap;
/** jumpbar有效 */
@property (nonatomic, assign) CGFloat slideLineWidth;
@property (nonatomic, strong) UIColor *botLineColor;
@property (nonatomic, assign) CGFloat botLineHeight;
/** 以下对HCTabPageEquantBar有效 */
@property (nonatomic, assign) CGSize vLineSize;
@property (nonatomic, strong) UIColor *vLineColor;
/** 滑动线均分 */
@property (nonatomic, assign) BOOL equalSlideLineWidth;

/** 只要selIndex变化，则移动对应的Item到显示位置 */
@property (nonatomic, assign) BOOL realTimeMoveSelItem;
@property (nonatomic, assign) BOOL gradientTitleColor;
@property (nonatomic, assign) BOOL gradientTitleFont;

/** 自定义属性 */
@property (nonatomic, strong) NSDictionary *otherAttri;

/** tablePageView所在的控制器 */
@property (nonatomic, weak) UIViewController *tablePageViewVc;
- (void)tablePageViewLayoutSubviews;
@end
