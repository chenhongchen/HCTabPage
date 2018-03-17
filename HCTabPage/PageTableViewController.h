//
//  PageTableViewController.h
//  HCTabPage
//
//  Created by chc on 2017/12/24.
//  Copyright © 2017年 CHC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PageTableViewController;
@protocol PageTableViewControllerDelegate <NSObject>
- (void)pageTableViewController:(PageTableViewController *)pageTableViewController didScrollForScrollView:(UIScrollView *)scrollView;
@end

@interface PageTableViewController : UITableViewController
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) Class detineClass;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, weak) id <PageTableViewControllerDelegate> delegate;
- (void)setupOffsetY:(CGFloat)offsetY;
@end
