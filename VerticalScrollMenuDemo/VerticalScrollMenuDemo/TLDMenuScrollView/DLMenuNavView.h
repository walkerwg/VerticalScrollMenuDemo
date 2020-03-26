//
//  DLMenuNavView.h
//  WXTest
//
//  Created by SL on 15/1/4.
//  Copyright (c) 2015年 Sheng Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLMenuNavView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                    menuNames:(NSArray *)menuNames
                  normalColor:(UIColor *)normalColor
                selectedColor:(UIColor *)selectedColor
                         font:(UIFont *)font
                        space:(CGFloat)space
                      showLoc:(void(^)(NSInteger index))showLoc;

/**
 *  指定选中的位置
 *
 *  @param index    位置
 *  @param animated 是否带有动画
 */
- (void)setSelected:(NSInteger)index animated:(BOOL)animated;

/**
 *  DLMenuScrollView执行scrollViewDidScroll时调用
 *
 *  @param gap       间隔
 *  @param movingLoc 移动到的位置
 */
- (void)moveLoc:(CGFloat)gap movingLoc:(CGFloat)movingLoc;

/**
 *  刷新数据源
 *
 *  @param menuNames   显示title
 */
- (void)reloadData:(NSArray *)menuNames;

/**
 *  菜单显示
 */
@property (nonatomic,readonly) UIScrollView *scrollView;

/**
 *  获取当前选中位置
 */
@property (nonatomic,readonly) NSInteger selectIndex;

/**
 *  下面选中标识view
 */
@property (nonatomic, readonly) UIView *selectView;

/**
 不使用渐变，默认使用
 */
@property (nonatomic, assign) BOOL noUseFade;

/**
 设置选中view的frame
 */
@property (nonatomic, assign) CGRect selectRect;

/**
 当前选中的title
 */
@property (nonatomic, copy,readonly) NSString * selectedTitle;

/**
 底部的分割线（默认显示）
 */

@property (nonatomic, strong) UIView * seperatorLine;
/**
 *  独立使用居中显示
 */
- (void)fixedShowContent;


/**
 *  移动光标到指定位置
 */
- (void)moveBottomLineToIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 *  移动光标到指定tiltle的tab
 */
- (void)moveBottomLineToTitle:(NSString *)title animated:(BOOL)animated;


/**
 *  右边显示蒙版,默认不添加蒙版
 */
- (void)showMaskView;

/// 获取指定位置的标题
- (NSString *)titleAtIndex:(NSInteger)index;


@end
