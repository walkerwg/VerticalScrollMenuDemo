//
//  DLMenuScrollView.h
//  WXTest
//
//  Created by SL on 15/1/4.
//  Copyright (c) 2015年 Sheng Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLMenuNavView.h"
#import "DLMenuViewProtocol.h"

@interface DLMenuScrollView : UIView

/**
 *  菜单栏
 */
@property (nonatomic,readonly) DLMenuNavView *navView;

/**
 *  内容页
 */
@property (nonatomic,readonly) UIScrollView *scrollView;

/**
 有透视图时上下滑动的偏移量
 */
@property (nonatomic, strong) void(^mainScrollYContentOffsetBlock)(CGFloat yOffset);

/**
 *  自定义初始化方法
 *
 *  @param frame         位置
 *  @param headerView    头视图
 *  @param nameArray     显示的名称，NSString数组
 *  @param navHeigh      菜单高度
 *  @param normalIndex   默认选中位置
 *  @param normalColor   默认颜色
 *  @param selectedColor 选中颜色
 *  @param font          字体样式
 *  @param space      按钮间距

 *  @param currentView   获取当前页面
 *
 *  @return
 */
- (instancetype)initWithFrame:(CGRect)frame
                   headerView:(UIView *)headerView
                    nameArray:(NSArray *)nameArray
                    navHeight:(CGFloat)navHeigh
                  normalIndex:(NSInteger)normalIndex
                  normalColor:(UIColor *)normalColor
                selectedColor:(UIColor *)selectedColor
                         font:(UIFont *)font
                        space:(CGFloat)space
                  currentView:(UIView<DLMenuViewProtocol> *(^)(id x,NSInteger index,CGRect rect))currentView;

/**
 *  设置选中位置
 */
@property (nonatomic,assign) NSInteger selectIndex;

/**
 *  获取当前显示的子页面
 */
- (UIView *)fetchCurrentChildView;

/**
 获取指定位置的子页面

 @param index 子页面位置
 */
- (UIView * __nullable)fetchChildViewAtIndex:(NSInteger)index;

/**
 *  刷新数据源
 *
 *  @param nameArray   显示title
 *  @param selectIndex 选中位置
 */
- (void)reloadData:(NSArray *)nameArray selectIndex:(NSInteger)selectIndex;

/// 只刷新标签列表
/// @param titleArray 标签列表
- (void)reloadNavTitles:(NSArray *)titleArray;

/**
 *  获取当前选中位置
 */
@property (nonatomic,assign) NSInteger currentIndex;

/**
 设置固定button宽度的内容

 @param fixedWidth 设置button宽度，为0时是默认宽度
 @param loc 0居中，1居左
 */
- (void)fixedWidthShowContent:(CGFloat)fixedWidth
                          loc:(NSInteger)loc;

/**
 设置button固定间距
 
 @param fixedSpace 设置button间距，为0时是默认宽度
 */
- (void)fixedSpaceShowContent:(CGFloat)fixedSpace;

/**
 重置选中view的frame

 @param rect <#rect description#>
 */
- (void)resetSelectViewFrame:(CGRect)rect;

/// 重设frame
- (void)resetMenuScrollViewFrame:(CGRect)rect headerView:(UIView *)headerView nameArray:(NSArray *)nameArray selectedIndex:(NSInteger)selectedIndex;

@end
