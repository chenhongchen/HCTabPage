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
@end

@protocol HCTabPageViewDelegate <NSObject>
- (void)tabPageView:(HCTabPageView *)tabPageView didSelectTabBarAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex;
- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex formIndex:(NSInteger)formIndex;
@end

@interface HCTabPageView : UIView
@property (nonatomic, weak) id <HCTabPageViewDataSource> dataSource;
@property (nonatomic, weak) id <HCTabPageViewDelegate> delegate;
@property (nonatomic, weak) UIView *tabPageHeaderView;
/** 所在的控制器, 如不传会自动获取 */
@property (nonatomic, weak) UIViewController *ownVC;
/** 当前页索引 */
@property (nonatomic, assign) NSInteger curIndex;

- (instancetype)initWithBarStyle:(NSString *)barStyle;
+ (instancetype)tabPageViewWithBarStyle:(NSString *)barStyle;
- (void)reload;
- (void)setPageAtIndex:(NSInteger)index animation:(BOOL)animation;

/** tabPageBar 属性设置*/
@property (nonatomic, assign) CGFloat tabPageBarHeight;
/** 为0则和bar一样高 */
@property (nonatomic, assign) CGFloat btnHeight;
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
@property (nonatomic, strong) UIColor *slideLineColor;
@property (nonatomic, assign) CGFloat slideLineHeight;
@property (nonatomic, strong) UIColor *botLineColor;
@property (nonatomic, assign) CGFloat botLineHeight;
/** 只要selIndex变化，则移动对应的Item到显示位置 */
@property (nonatomic, assign) BOOL realTimeMoveSelItem;
/** 颜色渐变 */
@property (nonatomic, assign) BOOL gradientTitleColor;
/** 字体渐变 */
@property (nonatomic, assign) BOOL gradientTitleFont;
/** 穿透效果 */
@property (nonatomic, assign) BOOL passThrough;
/** 自定义属性 */
@property (nonatomic, strong) NSDictionary *otherAttri;
@end
