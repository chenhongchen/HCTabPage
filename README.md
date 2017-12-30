# HCTabPage
1、主要功能：一个类似腾讯视频的，页面切换框架，并可方便扩展自定义顶部bar;

2、使用：

2.1、初始化并设置代理

// BarStyle 定义在 HCTabPageConst.h 文件中 如果用Init初始化默认是TabPageScrollBar类型

HCTabPageView *tabPageView = [[HCTabPageView alloc] initWithBarStyle:TabPageScrollSLJumpBar];

[self.view addSubview:tabPageView];

tabPageView.dataSource = self;

tabPageView.delegate = self;

2.2、代理

//  HCTabPageViewDataSource

// 加载数据源有错误回调

- (void)tabPageView:(HCTabPageView *)tabPageView loadDataError:(NSString *)error；

// 返回总页数

- (NSInteger)numberOfPagesInTabPageView:(HCTabPageView *)tabPageView；

// 返回总页数

- (UIViewController *)tabPageView:(HCTabPageView *)tabPageView controllerForPageAtIndex:(NSInteger)index；

// 返回

- (NSString *)tabPageView:(HCTabPageView *)tabPageView titleForTabBarAtIndex:(NSInteger)index；

// HCTabPageViewDelegate

// 点击tab按钮事件回调

- (void)tabPageView:(HCTabPageView *)tabPageView didSelectTabBarAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex;

// 页面切换了回调

- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex formIndex:(NSInteger)formIndex；

2.3、自定义tabbar步骤

2.3.1、新建自定义bar文件，继承HCTabPageBar

2.3.2、重写下面两个方法

// tabPageView会自动传入HCTabPageView中scrollView的offsetX

- (void)setOffsetX:(CGFloat)offsetX animaton:(BOOL)animation;

// 比如tabPageView初始化时设置了curIndex，则会调用改方法，并传入index

- (void)selectTabAtIndex:(NSInteger)selIndex animation:(BOOL)animation;

2.3.3、自定义bar中可能需要用到的方法

// 获得一个数组、元素分别为offsetx对应的selIndex、leftIndex、rightIndex 、lRatio(offsetx到左边btn距离与左右btn之间距离的比)

- (NSArray *)positionsForPageOffsetX:(CGFloat)pageOffsetX;


