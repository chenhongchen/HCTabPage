//
//  HCTabPageView.m
//  HCTabPage
//
//  Created by chc on 2017/12/22.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import "HCTabPageView.h"
#import "HCTabPageBar.h"
#import "HCTabPageConst.h"
#import "HCTabPageScrollBar.h"
#import "HCTabPageTool.h"
#import "HCTPScrollView.h"

@interface HCTabPageView ()<UIScrollViewDelegate, HCTabPageBarDelegate>
@property (nonatomic, weak) HCTabPageBar *tabPageBar;
@property (nonatomic, copy) NSString *barStyle;
/** 页控制器容器 */
@property (nonatomic, weak) HCTPScrollView *pagesScrollView;
@property (nonatomic, weak) UIView *barBgView;
/** 页数 */
@property (nonatomic, assign) NSInteger pagesNumber;
/** 所有页控制器集合 */
@property (nonatomic, strong) NSArray <UIViewController *> *pageControllers;
/** 标题集合 */
@property (nonatomic, strong) NSArray *tabTitles;
/** 下一页索引 */
@property (nonatomic, assign) NSInteger nextIndex;
/** 当前页控制器 */
//@property (nonatomic, strong) UIViewController *curPageController;
/** 下一页控制器 */
//@property (nonatomic, strong) UIViewController *nextPageController;
/** 已显示且未执行消失的页控制器集合 */
@property (nonatomic, strong) NSArray *didAppearPageControllers;

@property (nonatomic, assign) BOOL hasFirstLayout;

@property (nonatomic, assign) UIInterfaceOrientation orientation;

/** 用于判断是否横滑了 */
@property (nonatomic, assign) CGFloat lastOffsetX;
@end

@implementation HCTabPageView

#pragma mark - 初始化
+ (instancetype)tabPageViewWithBarStyle:(NSString *)barStyle
{
    return [[self alloc] initWithBarStyle:barStyle];
}

- (instancetype)initWithBarStyle:(NSString *)barStyle
{
    _barStyle = barStyle;
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        if (![_barStyle isKindOfClass:[NSString class]] || !_barStyle.length) {
            _barStyle = TabPageScrollBar;
        }
        _tabPageBarHeight = 40;
        self.bgColor = [UIColor whiteColor];
        self.bounces = YES;
        self.scrollEnabled = YES;
    }
    return self;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self scrollViewAdaptation];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
    // reload配置的时候，需要已布局好了，不然界面会出现异常
    [self reloadAfterFristLayout];
    
    self.pagesScrollView.bounces = _bounces;
    self.pagesScrollView.scrollEnabled = _scrollEnabled;
    self.pagesScrollView.forbitLeftScrollPage = _forbitLeftScrollPage;
    self.pagesScrollView.forbitLeftScrollWidthRatio = _forbitLeftScrollWidthRatio;
    
    // 用于旋转时适配
    UIInterfaceOrientation orientatin = [UIApplication sharedApplication].statusBarOrientation;
    if (_orientation != orientatin) {
        self.pagesScrollView.contentSize = CGSizeMake(_pagesNumber * self.bounds.size.width, 0);
        self.pagesScrollView.contentOffset = CGPointMake(_curIndex * self.bounds.size.width, 0);
        _orientation = [UIApplication sharedApplication].statusBarOrientation;
        [self scrollViewDidScroll:self.pagesScrollView];
    }
    
    self.tabPageBar.tablePageViewVc = [self controllerForSelf];
    [self.tabPageBar tablePageViewLayoutSubviews];
}

- (void)dealloc
{
    [self clearSourceData];
}

- (void)scrollViewAdaptation
{
    if (@available(iOS 11.0, *)) {
        self.pagesScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        [self controllerForSelf].automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - 懒加载
- (HCTPScrollView *)pagesScrollView
{
    if (_pagesScrollView == nil) {
        HCTPScrollView *pagesScrollView = [[HCTPScrollView alloc] init];
        [self addSubview:pagesScrollView];
        _pagesScrollView = pagesScrollView;
        _pagesScrollView.pagingEnabled = YES;
        pagesScrollView.delegate = self;
        pagesScrollView.showsHorizontalScrollIndicator = NO;
        pagesScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _pagesScrollView;
}

- (HCTabPageBar *)tabPageBar
{
    if (_tabPageBar == nil) {
        HCTabPageBar *tabPageBar = [[NSClassFromString(_barStyle) alloc] init];
        [self addSubview:tabPageBar];
        _tabPageBar = tabPageBar;
        tabPageBar.delegate = self;
    }
    return _tabPageBar;
}

- (UIView *)barBgView
{
    if (_barBgView == nil) {
        UIView *barBgView = [[UIView alloc] init];
        [self addSubview:barBgView];
        _barBgView = barBgView;
    }
    return _barBgView;
}

#pragma mark - 外部方法
- (void)reload
{
    // reload配置的时候，需要已布局好了，不然界面会出现异常
    if (_hasFirstLayout) {
        self.pagesScrollView.delegate = nil;
        [self loadDataSource];
        
        if (_curIndex >= _pagesNumber) {
            _curIndex = (_pagesNumber > 0 ? _pagesNumber - 1 : 0);
            _nextIndex = _curIndex;
        }
        [self selectPageAtIndex:_curIndex animation:NO];
        [self.tabPageBar selectTabAtIndex:_curIndex animation:NO];
        self.pagesScrollView.delegate = self;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 好等bar刷新好才执行回调
            if ([_dataSource respondsToSelector:@selector(didLoadDataCompleteForTabPageView:)]) {
                [_dataSource didLoadDataCompleteForTabPageView:self];
            }
        });
    }
}

- (void)setPageAtIndex:(NSInteger)index animation:(BOOL)animation
{
    if (_pagesNumber <= 0) {
        return;
    }
    if (index < 0) {
        index = 0;
    }
    if (index > _pagesNumber - 1) {
        index = _pagesNumber - 1;
    }
    [self selectPageAtIndex:index animation:animation];
    [self.tabPageBar selectTabAtIndex:index animation:animation];
}

- (void)setOwnVC:(UIViewController *)ownVC
{
    if ([ownVC isKindOfClass:[UIViewController class]]) {
        _ownVC = ownVC;
        UIViewController *pageController = self.pageControllers[_curIndex];
        if ([pageController isKindOfClass:[UIViewController class]]) {
            [_ownVC addChildViewController:pageController];
        }
    }
}

- (void)setTabPageHeaderView:(UIView *)tabPageHeaderView
{
    if (tabPageHeaderView != _tabPageHeaderView) {
        [_tabPageHeaderView removeFromSuperview];
        [self addSubview:tabPageHeaderView];
        _tabPageHeaderView = tabPageHeaderView;
    }
    [self setupFrame];
}

- (void)setCurIndex:(NSInteger)curIndex
{
    _curIndex = curIndex;
    _nextIndex = curIndex;
}

- (NSArray *)childControllers
{
    return _pageControllers;
}

- (void)refreshFrame
{
    [self setupFrame];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    self.pagesScrollView.scrollEnabled = _scrollEnabled;
}

- (UIButton *)barBtnAtIndex:(NSInteger)index
{
    return [self.tabPageBar barBtnAtIndex:index];
}

#pragma mark - tabPageBar 属性设置
- (void)setTabPageBarEnable:(BOOL)tabPageBarEnable
{
    _tabPageBarEnable = tabPageBarEnable;
    self.tabPageBar.userInteractionEnabled = _tabPageBarEnable;
}

- (void)setTabPageBarHeight:(CGFloat)tabPageBarHeight
{
    _tabPageBarHeight = tabPageBarHeight;
    CGRect rect = self.tabPageBar.frame;
    rect.size.height = _tabPageBarHeight;
    self.tabPageBar.frame = rect;
}

- (void)setBtnHeight:(CGFloat)btnHeight
{
    _btnHeight = btnHeight;
    self.tabPageBar.btnHeight = _btnHeight;
}

- (void)setNavBarSzie:(CGSize)navBarSzie
{
    _navBarSzie = navBarSzie;
    self.tabPageBar.navBarSzie = _navBarSzie;
}

- (void)setNavItem:(UINavigationItem *)navItem
{
    _navItem = navItem;
    self.tabPageBar.navItem = _navItem;
}

- (void)setHasBtnAnimation:(BOOL)hasBtnAnimation
{
    _hasBtnAnimation = hasBtnAnimation;
    self.tabPageBar.hasBtnAnimation = _hasBtnAnimation;
}

- (void)setLeftMargin:(CGFloat)leftMargin
{
    _leftMargin = leftMargin;
    self.tabPageBar.leftMargin = _leftMargin;
}

- (void)setRightMargin:(CGFloat)rightMargin
{
    _rightMargin = rightMargin;
    self.tabPageBar.rightMargin = _rightMargin;
}

- (void)setPadding:(CGFloat)padding
{
    _padding = padding;
    self.tabPageBar.padding = _padding;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.tabPageBar.titleFont = _titleFont;
}

- (void)setSelTitleFont:(UIFont *)selTitleFont
{
    _selTitleFont = selTitleFont;
    self.tabPageBar.selTitleFont = _selTitleFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.tabPageBar.titleColor = _titleColor;
}

- (void)setSelTitleColor:(UIColor *)selTitleColor
{
    _selTitleColor = selTitleColor;
    self.tabPageBar.selTitleColor = _selTitleColor;
}

- (void)setBgColor:(UIColor *)bgColor
{
    _bgColor = bgColor;
    self.barBgView.backgroundColor = _bgColor;
}

- (void)setBarBgColor:(UIColor *)barBgColor
{
    _barBgColor = barBgColor;
    self.tabPageBar.bgColor = _barBgColor;
}

- (void)setSlideLineColor:(UIColor *)slideLineColor
{
    _slideLineColor = slideLineColor;
    self.tabPageBar.slideLineColor = _slideLineColor;
}

- (void)setSlideLineHeight:(CGFloat)slideLineHeight
{
    _slideLineHeight = slideLineHeight;
    self.tabPageBar.slideLineHeight = _slideLineHeight;
}

- (void)setSlideLineWidth:(CGFloat)slideLineWidth
{
    _slideLineWidth = slideLineWidth;
    self.tabPageBar.slideLineWidth = _slideLineWidth;
}

- (void)setBotLineColor:(UIColor *)botLineColor
{
    _botLineColor = botLineColor;
    self.tabPageBar.botLineColor = _botLineColor;
}

- (void)setBotLineHeight:(CGFloat)botLineHeight
{
    _botLineHeight = botLineHeight;
    self.tabPageBar.botLineHeight = _botLineHeight;
}

- (void)setVLineSize:(CGSize)vLineSize
{
    _vLineSize = vLineSize;
    self.tabPageBar.vLineSize = _vLineSize;
}

- (void)setVLineColor:(UIColor *)vLineColor
{
    _vLineColor = vLineColor;
    self.tabPageBar.vLineColor = _vLineColor;
}

- (void)setEqualSlideLineWidth:(BOOL)equalSlideLineWidth
{
    _equalSlideLineWidth = equalSlideLineWidth;
    self.tabPageBar.equalSlideLineWidth = _equalSlideLineWidth;
}

- (void)setRealTimeMoveSelItem:(BOOL)realTimeMoveSelItem
{
    _realTimeMoveSelItem = realTimeMoveSelItem;
    self.tabPageBar.realTimeMoveSelItem = _realTimeMoveSelItem;
}

- (void)setGradientTitleColor:(BOOL)gradientTitleColor
{
    _gradientTitleColor = gradientTitleColor;
    self.tabPageBar.gradientTitleColor = _gradientTitleColor;
}

- (void)setGradientTitleFont:(BOOL)gradientTitleFont
{
    _gradientTitleFont = gradientTitleFont;
    self.tabPageBar.gradientTitleFont = _gradientTitleFont;
}

- (void)setOtherAttri:(NSDictionary *)otherAttri
{
    _otherAttri = otherAttri;
    self.tabPageBar.otherAttri = _otherAttri;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIInterfaceOrientation orientatin = [UIApplication sharedApplication].statusBarOrientation;
    if (_orientation == orientatin) {// 没有旋转才调用这些方法
        if ([self.delegate respondsToSelector:@selector(tabPageViewDidScroll:scrollView:)]) {
            [self.delegate tabPageViewDidScroll:self scrollView:scrollView];
        }
        [self setupNextAndCurIndex];
        [self setupNextAndCurPageControllerForShow];
        [self.tabPageBar setOffsetX:scrollView.contentOffset.x animaton:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(tabPageViewWillBeginDragging:scrollView:)]) {
        [self.delegate tabPageViewWillBeginDragging:self scrollView:scrollView];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.delegate respondsToSelector:@selector(tabPageViewDidEndDragging:willDecelerate:scrollView:)]) {
        [self.delegate tabPageViewDidEndDragging:self willDecelerate:decelerate scrollView:scrollView];
    }
}

// 滚动视图停止时调用
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSUInteger page = scrollView.contentOffset.x / self.bounds.size.width;
//    if (_curIndex == page) { // 没有翻页
//    }
//    else // 有翻页
//    {
//    }
//}

#pragma mark - HCTabPageBarDelegate
- (void)tabPageBar:(HCTabPageBar *)tabPageBar didSelectItemAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex animation:(BOOL)animation
{
    if ([self.delegate respondsToSelector:@selector(tabPageView:didSelectTabBarAtIndex:fromIndex:)]) {
        [self.delegate tabPageView:self didSelectTabBarAtIndex:atIndex fromIndex:fromIndex];
    }
    
    if ([self.delegate respondsToSelector:@selector(tabPageView:willChangePageToIndex:fromIndex:)] && atIndex != fromIndex) {
        [self.delegate tabPageView:self willChangePageToIndex:atIndex fromIndex:fromIndex];
    }
    
    [self selectPageAtIndex:atIndex animation:animation];
}

#pragma mark - 内部方法
- (void)reloadAfterFristLayout
{
    if (!_hasFirstLayout) {
        _hasFirstLayout = YES;
        [self reload];
    }
}

- (void)clearSourceData
{
//    _curIndex = 0;
//    _nextIndex = 0;
    _pagesNumber = 0;
    for (UIViewController *pageVc in _pageControllers) {
        if (pageVc.isViewLoaded) {
            [pageVc.view removeFromSuperview];
        }
        [pageVc removeFromParentViewController];
    }
    _pageControllers = nil;
    _tabTitles = nil;
    
    self.pagesScrollView.contentSize = CGSizeMake(0, 0);
}

/** 滑动时设置下一页索引和当前页索引、滑动停止时disappear其他已显示的页 */
- (void)setupNextAndCurIndex
{
    if (self.lastOffsetX == self.pagesScrollView.contentOffset.x) { //  不是横向滑动则直接返回
        return;
    }
    _lastOffsetX = self.pagesScrollView.contentOffset.x;
    CGFloat offset = self.pagesScrollView.contentOffset.x / self.bounds.size.width;
    // 1.滑动停止
    if (offset == floor(offset)) {
        UIViewController *curPageVc = _pageControllers[_curIndex];
        UIViewController *nextPageVc = _pageControllers[_nextIndex];
        // 1.1.换页了
        if (curPageVc.view.frame.origin.x != self.pagesScrollView.contentOffset.x) {
            _curIndex = _nextIndex;
            NSInteger firstIndex = [_pageControllers indexOfObject:_didAppearPageControllers.firstObject];
            if (/*firstIndex != _curIndex &&*/ [self.delegate respondsToSelector:@selector(tabPageView:didChangePageToIndex:fromIndex:)]) {
                [self.delegate tabPageView:self didChangePageToIndex:_nextIndex fromIndex:firstIndex];
            }
            
            // disappear所有未在当前显示的页
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_didAppearPageControllers];
            for (UIViewController *pageVc in _didAppearPageControllers) {
                if (pageVc != nextPageVc) {
                    [pageVc.view removeFromSuperview];
//                    [pageVc beginAppearanceTransition:NO animated:YES];
//                    [pageVc endAppearanceTransition];
                    [arrayM removeObject:pageVc];
                }
            }
            _didAppearPageControllers = arrayM;
        }
        // 1.2.没换页
        else {
            [curPageVc beginAppearanceTransition:YES animated:YES];
            [curPageVc endAppearanceTransition];
            NSInteger firstIndex = [_pageControllers indexOfObject:_didAppearPageControllers.firstObject];
            if (/*firstIndex != _curIndex &&*/ [self.delegate respondsToSelector:@selector(tabPageView:didChangePageToIndex:fromIndex:)]) {
                [self.delegate tabPageView:self didChangePageToIndex:_curIndex fromIndex:firstIndex];
            }
            
            // disappear所有未在当前显示的页
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_didAppearPageControllers];
            for (UIViewController *pageVc in _didAppearPageControllers) {
                if (pageVc != curPageVc) {
                    [pageVc.view removeFromSuperview];
//                    [pageVc beginAppearanceTransition:NO animated:YES];
//                    [pageVc endAppearanceTransition];
                    [arrayM removeObject:pageVc];
                }
            }
            _didAppearPageControllers = arrayM;
            _nextIndex = _curIndex;
        }
    }
    // 2.向右滑
    else if (_curIndex - offset > 0.003) {
        NSInteger toIndex = floor(offset) < 0 ? 0 : floor(offset);
        if (_nextIndex != toIndex) {
            if ([self.delegate respondsToSelector:@selector(tabPageView:willChangePageToIndex:fromIndex:)]) {
                [self.delegate tabPageView:self willChangePageToIndex:toIndex fromIndex:_curIndex];
            }
        }
        _nextIndex = floor(offset);
        _nextIndex = MAX(0, floor(offset));
        _curIndex = _nextIndex + 1;
        if (offset < 0) {
            _curIndex = 0;
        }
    }
    // 3.向左滑
    else if (offset - _curIndex > 0.003) {
        NSInteger toIndex = ceil(offset) > _pagesNumber - 1 ? _pagesNumber - 1 : ceil(offset);
        if (_nextIndex != toIndex) {
            if ([self.delegate respondsToSelector:@selector(tabPageView:willChangePageToIndex:fromIndex:)]) {
                [self.delegate tabPageView:self willChangePageToIndex:toIndex fromIndex:_curIndex];
            }
        }
        _nextIndex = ceil(offset);
        _nextIndex = MIN(ceil(offset), _pagesNumber - 1);
        _curIndex = _nextIndex - 1;
        if (offset > _pagesNumber - 1) {
            _curIndex = _pagesNumber - 1;
        }
    }
    // 4.未滑动
    else {
    }
}

/** 滑动时设置下一页和当前页控制器，appear下一页控制器 */
- (void)setupNextAndCurPageControllerForShow
{
    if (!(_nextIndex >= 0 && _nextIndex < _pagesNumber)) {
        return;
    }
    
    UIViewController *nextPageVc = _pageControllers[_nextIndex];
    
    // page控制器初次添加到容器，会自动appear
    if (!nextPageVc.view.superview) {
        [self.pagesScrollView addSubview:nextPageVc.view];
        [[self controllerForSelf] addChildViewController:nextPageVc];
        if (![_didAppearPageControllers containsObject:nextPageVc]) {
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_didAppearPageControllers];
            [arrayM addObject:nextPageVc];
            _didAppearPageControllers = arrayM;
        }
    }
    // page控制器已添加到容器，要手动appear(由于采用未在当前显示的page，view都被移除了方案，所以该分支暂未使用)
    else if (![_didAppearPageControllers containsObject:nextPageVc]) {
        [nextPageVc beginAppearanceTransition:YES animated:NO];
        [nextPageVc endAppearanceTransition];
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_didAppearPageControllers];
        [arrayM addObject:nextPageVc];
        _didAppearPageControllers = arrayM;
    }
    
    CGFloat width = self.pagesScrollView.bounds.size.width;
    CGFloat height = self.pagesScrollView.bounds.size.height;
    CGFloat x = _nextIndex * width;
    CGFloat y = 0;
    nextPageVc.view.frame = CGRectMake(x, y, width, height);
}

/** 设置显示在指定页，appear指定页、disappear其他已显示的页 */
- (void)selectPageAtIndex:(NSInteger)index animation:(BOOL)animation
{
    _nextIndex = index;
    
    UIViewController *nextPageVc = _pageControllers[_nextIndex];
    // page控制器初次添加到容器，会自动appear
    if ([nextPageVc isKindOfClass:[UIViewController class]] && !nextPageVc.view.superview) {
        [self.pagesScrollView addSubview:nextPageVc.view];
        [[self controllerForSelf] addChildViewController:nextPageVc];
        if (![_didAppearPageControllers containsObject:nextPageVc]) {
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_didAppearPageControllers];
            [arrayM addObject:nextPageVc];
            _didAppearPageControllers = arrayM;
        }
    }
    // page控制器已添加到容器，要手动appear(由于采用未在当前显示的page，view都被移除了方案，所以该分支暂未使用)
    else if (![_didAppearPageControllers containsObject:nextPageVc]) {
        [nextPageVc beginAppearanceTransition:YES animated:NO];
        [nextPageVc endAppearanceTransition];
        NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_didAppearPageControllers];
        if ([nextPageVc isKindOfClass:[UIViewController class]]) {
            [arrayM addObject:nextPageVc];
        }
        _didAppearPageControllers = arrayM;
    }
    
    CGFloat width = self.pagesScrollView.bounds.size.width;
    CGFloat height = self.pagesScrollView.bounds.size.height;
    CGFloat y = 0;
    CGFloat x = (_curIndex + ((_nextIndex > _curIndex) ? 1 : -1)) * width;
    if (_curIndex == _nextIndex) {
        x = _curIndex * width;
        nextPageVc.view.frame = CGRectMake(x, y, width, height);
        self.pagesScrollView.contentOffset = CGPointMake(_nextIndex * width, 0);
    }
    else
    {
        _curIndex = _nextIndex;
        nextPageVc.view.frame = CGRectMake(x, y, width, height);
        _pagesScrollView.delegate = nil;
        [UIView animateWithDuration:(animation ? kTP_AniDuration : 0) animations:^{
            self.pagesScrollView.contentOffset = CGPointMake(x, 0);
        } completion:^(BOOL finished) {
            UIViewController *nextPageVc = _pageControllers[_nextIndex];
            nextPageVc.view.frame = CGRectMake(_nextIndex * width, y, width, height);
            self.pagesScrollView.contentOffset = CGPointMake(_nextIndex * width, 0);
            _pagesScrollView.delegate = self;
            
            NSInteger firstIndex = [_pageControllers indexOfObject:_didAppearPageControllers.firstObject];
            if ([self.delegate respondsToSelector:@selector(tabPageView:didChangePageToIndex:fromIndex:)] && index != firstIndex) {
                [self.delegate tabPageView:self didChangePageToIndex:_nextIndex fromIndex:firstIndex];
            }
            
            // disappear所有未在当前显示的页
            NSMutableArray *arrayM = [NSMutableArray arrayWithArray:_didAppearPageControllers];
            for (UIViewController *pageVc in _didAppearPageControllers) {
                if (pageVc != nextPageVc) {
                    [pageVc.view removeFromSuperview];
//                    [pageVc beginAppearanceTransition:NO animated:YES];
//                    [pageVc endAppearanceTransition];
                    [arrayM removeObject:pageVc];
                }
            }
            _didAppearPageControllers = arrayM;
        }];
    }
}

- (void)setupFrame
{
    CGFloat height = _tabPageBarHeight;
    CGFloat width = self.bounds.size.width;
    CGFloat x = 0;
    CGFloat y = _passThrough ? CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) : 0;
    if (_barY > 0) {
        y = _barY;
    }
    self.tabPageBar.frame = CGRectMake(x, y, width, height);
    
    if ([_tabPageHeaderView isKindOfClass:[UIView class]]) {
        CGRect rect = _tabPageHeaderView.bounds;
        rect.origin.y = CGRectGetMaxY(self.tabPageBar.frame);
        rect.size.width = self.bounds.size.width;
        _tabPageHeaderView.frame = rect;
    }
    
    width = self.bounds.size.width;
    height = MAX(CGRectGetMaxY(_tabPageHeaderView.frame), CGRectGetMaxY(self.tabPageBar.frame));
    x = 0;
    y = 0;
    self.barBgView.frame = CGRectMake(x, y, width, height);
    
    x = 0;
    y = (_passThrough/* || _barY > 0*/) ? 0 : CGRectGetMaxY(self.barBgView.frame);
    width = self.bounds.size.width;
    height = self.bounds.size.height - y;
    self.pagesScrollView.frame = CGRectMake(x, y, width, height);
//    [self bringSubviewToFront:self.tabPageBar];
    [self sendSubviewToBack:self.pagesScrollView];
}

- (UIViewController *)controllerForSelf {
    if (_ownVC) {
        return _ownVC;
    }
    return [HCTabPageTool controllerForView:self];
}

- (void)setupTabPageBar
{
    self.tabPageBar.titles = _tabTitles;
}

/** 加载数据源 */
- (void)loadDataSource
{
    [self clearSourceData];
    
    if (self.bounds.size.width <= 0 || self.bounds.size.height <= 0) {
        [self clearSourceData];
        if ([_dataSource respondsToSelector:@selector(tabPageView:loadDataError:)]) {
            [_dataSource tabPageView:self loadDataError:@"tabPageView宽或高等于零"];
        }
        return;
    }
    
    if ([_dataSource respondsToSelector:@selector(numberOfPagesInTabPageView:)]) {
        _pagesNumber = [_dataSource numberOfPagesInTabPageView:self];
    }
    else
    {
        [self clearSourceData];
        return;
    }
    
    if ([_dataSource respondsToSelector:@selector(tabPageView:controllerForPageAtIndex:)] && _pagesNumber > 0) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSInteger i = 0; i < _pagesNumber; i ++) {
            UIViewController *pageController = [_dataSource tabPageView:self controllerForPageAtIndex:i];
            if (![pageController isKindOfClass:[UIViewController class]]) {
                [self clearSourceData];
                if ([_dataSource respondsToSelector:@selector(tabPageView:loadDataError:)]) {
                    [_dataSource tabPageView:self loadDataError:@"提供了错误的page控制器"];
                }
                break;
            }
//            [[self controllerForSelf] addChildViewController:pageController]; 不能一起加，偶尔会执行viewdidload
            [arrayM addObject:pageController];
        }
        _pageControllers = arrayM;
    }
    else
    {
        [self clearSourceData];
        return;
    }
    
    if ([_dataSource respondsToSelector:@selector(tabPageView:titleForTabBarAtIndex:)] && _pagesNumber > 0) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSInteger i = 0; i < _pagesNumber; i ++) {
            NSString *tabTilte = [_dataSource tabPageView:self titleForTabBarAtIndex:i];
            if (![tabTilte isKindOfClass:[NSString class]]) {
                [self clearSourceData];
                if ([_dataSource respondsToSelector:@selector(tabPageView:loadDataError:)]) {
                    [_dataSource tabPageView:self loadDataError:@"提供了错误的title"];
                }
                break;
            }
            [arrayM addObject:tabTilte];
        }
        _tabTitles = arrayM;
    }
    else
    {
        [self clearSourceData];
        return;
    }
    
    self.pagesScrollView.contentSize = CGSizeMake(_pagesNumber * self.bounds.size.width, 0);
    self.tabPageBar.titles = _tabTitles;
}
@end
