# HCTabPage
## 1、主要功能：一个类似腾讯视频的页面切换框架，可方便扩展自定义顶部bar，有对每个子控制器生命周期进行控制；

## 2、效果展示

展示1：

![gif](https://github.com/chenhongchen/HCTabPage/blob/master/scrollbar1.gif)

展示2：

![gif](https://github.com/chenhongchen/HCTabPage/blob/master/scrollbar2.gif)

## 3、使用：

### 3.1、初始化并设置代理

```
// BarStyle 定义在 HCTabPageConst.h 文件中 如果用Init初始化默认是TabPageScrollBar类型
HCTabPageView *tabPageView = [[HCTabPageView alloc] initWithBarStyle:TabPageScrollSLJumpBar];
[self.view addSubview:tabPageView];
tabPageView.dataSource = self;
tabPageView.delegate = self;
```

### 3.2、代理

#### 3.2.1、  HCTabPageViewDataSource

```
// 加载数据源有错误回调
- (void)tabPageView:(HCTabPageView *)tabPageView loadDataError:(NSString *)error;

// 返回总页数
- (NSInteger)numberOfPagesInTabPageView:(HCTabPageView *)tabPageView;

// 返回子控制器
- (UIViewController *)tabPageView:(HCTabPageView *)tabPageView controllerForPageAtIndex:(NSInteger)index;

// 返回tabbtn的标题
- (NSString *)tabPageView:(HCTabPageView *)tabPageView titleForTabBarAtIndex:(NSInteger)index;
```

#### 3.2.2、 HCTabPageViewDelegate

```
// 点击tab按钮事件回调
- (void)tabPageView:(HCTabPageView *)tabPageView didSelectTabBarAtIndex:(NSInteger)atIndex fromIndex:(NSInteger)fromIndex;

// 页面切换了回调
- (void)tabPageView:(HCTabPageView *)tabPageView didChangePageToIndex:(NSInteger)toIndex formIndex:(NSInteger)formIndex;
```

### 3.3、自定义tabbar步骤

#### 3.3.1、新建自定义bar文件，继承HCTabPageBar

#### 3.3.2、重写下面两个方法

```
// tabPageView会适时调用该方法，并传入offsetX
- (void)setOffsetX:(CGFloat)offsetX animaton:(BOOL)animation;

// tabPageView会适时调用该方法，并传入index
- (void)selectTabAtIndex:(NSInteger)selIndex animation:(BOOL)animation;
```

#### 3.3.3、自定义bar中可能需要用到的方法
```
// 获得一个数组、元素分别为offsetx对应的selIndex、leftIndex、rightIndex 、lRatio(offsetx到左边btn距离与左右btn之间距离的比)
- (NSArray *)positionsForPageOffsetX:(CGFloat)pageOffsetX;
```


