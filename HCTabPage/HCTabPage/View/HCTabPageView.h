//
//  HCTabPageView.h
//  HCTabPage
//
//  Created by chc on 2017/12/22.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCTabPageView;
@protocol HCTabPageViewDataSource <NSObject>
@required
- (NSInteger)numberOfPagesInTabPageView:(HCTabPageView *)tabPageView;
- (NSString *)tabPageView:(HCTabPageView *)tabPageView titleForTabBarAtIndex:(NSInteger)index;
- (UIViewController *)tabPageView:(HCTabPageView *)tabPageView controllerForPageAtIndex:(NSInteger)index;

@optional
- (void)tabPageView:(HCTabPageView *)tabPageView loadDataError:(NSString *)error;
- (void)didLoadDataCompleteForTabPageView:(HCTabPageView *)tabPageView;
@end

@protocol HCTabPageViewDelegate <NSObject>
@optional
- (void)tabPageView:(HCTabPageView *)tabPageView didSelectTabBarAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex;
- (void)tabPageView:(HCTabPageView *)tabPageView willChangePageToIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex;
- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex;
- (void)tabPageViewDidScroll:(HCTabPageView *)tabPageView;
@end

@interface HCTabPageView : UIView
@property (nonatomic, weak) id <HCTabPageViewDataSource> dataSource;
@property (nonatomic, weak) id <HCTabPageViewDelegate> delegate;
@property (nonatomic, weak) UIView *tabPageHeaderView;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) BOOL scrollEnabled;
/** 所在的控制器, 如不传会自动获取 */
@property (nonatomic, weak) UIViewController *ownVC;
/** 所有子控制器 */
@property (nonatomic, strong, readonly) NSArray *childControllers;
/** 当前页索引 */
@property (nonatomic, assign) NSInteger curIndex;

- (instancetype)initWithBarStyle:(NSString *)barStyle;
+ (instancetype)tabPageViewWithBarStyle:(NSString *)barStyle;
- (void)reload;
- (void)setPageAtIndex:(NSInteger)index animation:(BOOL)animation;

- (void)refreshFrame;

/** 获取barBtn */
- (UIButton *)barBtnAtIndex:(NSInteger)index;

/** 禁止左滑有效宽度（0 ~ 1），用于侧滑返回*/
@property (nonatomic, assign) CGFloat forbitLeftScrollWidthRatio;
/** 禁止左滑页，用于侧滑返回*/
@property (nonatomic, assign) NSInteger forbitLeftScrollPage;

/** tabPageBar 属性设置*/
@property (nonatomic, assign) BOOL tabPageBarEnable;
@property (nonatomic, assign) CGFloat tabPageBarHeight;
/** 为0则和bar一样高 */
@property (nonatomic, assign) CGFloat btnHeight;
@property (nonatomic, assign) CGSize navBarSzie;
/** btn 的 frame变化是否有动画 */
@property (nonatomic, assign) BOOL hasBtnAnimation;
@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *selTitleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *selTitleColor;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *barBgColor;
@property (nonatomic, strong) UIColor *slideLineColor;
@property (nonatomic, assign) CGFloat slideLineHeight;
@property (nonatomic, strong) UIColor *botLineColor;
@property (nonatomic, assign) CGFloat botLineHeight;

/** 以下对HCTabPageEquantBar有效 */
@property (nonatomic, assign) CGSize vLineSize;
@property (nonatomic, strong) UIColor *vLineColor;
/** 滑动线均分 */
@property (nonatomic, assign) BOOL equalSlideLineWidth;

/** 只要selIndex变化，则移动对应的Item到显示位置 */
@property (nonatomic, assign) BOOL realTimeMoveSelItem;
/** 颜色渐变 */
@property (nonatomic, assign) BOOL gradientTitleColor;
/** 字体渐变 */
@property (nonatomic, assign) BOOL gradientTitleFont;
/** 穿透效果 */
@property (nonatomic, assign) BOOL passThrough;
/** bar离顶部的距离(barY大于0则passThrough效果用barY代替) */
@property (nonatomic, assign) CGFloat barY;
/** 自定义属性 */
@property (nonatomic, strong) NSDictionary *otherAttri;
@end
