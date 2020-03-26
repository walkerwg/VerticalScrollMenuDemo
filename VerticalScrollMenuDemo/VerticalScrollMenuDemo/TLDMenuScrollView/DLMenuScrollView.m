//
//  DLMenuScrollView.m
//  WXTest
//
//  Created by SL on 15/1/4.
//  Copyright (c) 2015年 Sheng Long. All rights reserved.
//

#import "DLMenuScrollView.h"
#import "DLMenuContentView.h"
#import "UITableView+DLMenuDelegate.h"

typedef UIView<DLMenuViewProtocol>* (^SelectView)(id x,NSInteger index,CGRect rect);

@interface DLMenuScrollView()<UIScrollViewDelegate, UITableViewDelegate>

/**
 *  显示名称，字符串数组
 */
@property (nonatomic,strong) NSArray *nameArray;

/**
 *  导航高度
 */
@property (nonatomic,assign) CGFloat navHeight;

/**
 *  菜单栏
 */
@property (nonatomic,strong) DLMenuNavView *navView;

/**
 *  内容页
 */
@property (nonatomic,strong) UIScrollView *scrollView;

/**
 *  获取当前页面
 */
@property (nonatomic,copy) SelectView selectViewBlock;

/**
 *  是否刚开始拖动
 */
@property (nonatomic,assign) BOOL startTracking;

/**
 *  不影响外面设置tag值，里面用字典替代
 */
@property (nonatomic,strong) NSMutableDictionary<NSString *,DLMenuContentView *> *viewDictionarys;

/**
 *  NO，执行selectIndex的set属性里面方法，YES不执行
 */
@property (nonatomic,assign) BOOL propertyMethod;

/**
 最外层的scrollView
 */
@property (nonatomic, strong) UIScrollView *mainScrollView;

/**
 开始滑动时子视图scrollView的偏移量
 */
@property (nonatomic, assign) CGPoint contentScrollViewOffset;

/**
 头视图高度
 */
@property (nonatomic, assign) CGFloat headerViewHeight;

/// 头视图
@property (nonatomic, strong) UIView *headerView;

@end

@implementation DLMenuScrollView

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"dealloc -- %@",self.class);
#endif
}

- (instancetype)initWithFrame:(CGRect)frame
                   headerView:(UIView *)headerView
                    nameArray:(NSArray *)nameArray
                    navHeight:(CGFloat)navHeigh
                  normalIndex:(NSInteger)normalIndex
                  normalColor:(UIColor *)normalColor
                selectedColor:(UIColor *)selectedColor
                         font:(UIFont *)font
                        space:(CGFloat)space
                  currentView:(UIView<DLMenuViewProtocol> *(^)(id x,NSInteger index,CGRect rect))currentView{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.viewDictionarys = [NSMutableDictionary<NSString *,DLMenuContentView *> new];
        
        self.nameArray = nameArray;
        self.navHeight = navHeigh;
        self.selectViewBlock = currentView;
        
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainScrollView.scrollEnabled = NO;
        [self addSubview:_mainScrollView];
        
        _headerView = headerView;
        _headerViewHeight = 0;
        if (headerView) {
            [_mainScrollView addSubview:headerView];
            _mainScrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height+headerView.bounds.size.height);
            _headerViewHeight = headerView.bounds.size.height;
        }
        else {
            _mainScrollView.contentSize = self.bounds.size;
        }
        
        __weak DLMenuScrollView *blockSelf = self;
        DLMenuNavView *navView = [[DLMenuNavView alloc] initWithFrame:CGRectMake(0, _headerViewHeight, self.frame.size.width, navHeigh)
                                                            menuNames:self.nameArray
                                                          normalColor:normalColor
                                                        selectedColor:selectedColor
                                                                 font:font
                                                                space:space
                                                              showLoc:^(NSInteger index) {
                                                                  [blockSelf.scrollView setContentOffset:CGPointMake(blockSelf.scrollView.frame.size.width * index, 0) animated:NO];
                                                                  [blockSelf getShowPage:index];
                                                              }];
        self.navView = navView;
        [_mainScrollView addSubview:navView];
        navView.backgroundColor = [UIColor clearColor];
        
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navView.frame), self.frame.size.width, self.frame.size.height-CGRectGetHeight(navView.frame))];
        self.scrollView = scrollView;
        [scrollView setBounces:NO];
        scrollView.scrollsToTop = NO;
        [scrollView setContentSize:CGSizeMake(frame.size.width*self.nameArray.count, 0)];
        [scrollView setDelegate:self];
        [scrollView setPagingEnabled:YES];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [_mainScrollView insertSubview:scrollView belowSubview:navView];
        
        _selectIndex = -1;
        self.selectIndex = normalIndex;
    }
    return self;
}

- (void)reloadData:(NSArray *)nameArray selectIndex:(NSInteger)selectIndex {
    self.nameArray = nameArray;
    [self.viewDictionarys removeAllObjects];
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DLMenuContentView class]]) {
            [obj removeFromSuperview];
            [self.scrollView removeGestureRecognizer:[(DLMenuContentView *)obj scrollView].panGestureRecognizer];
        }
    }];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*self.nameArray.count, 0);
    [self.navView reloadData:nameArray];
    
    self.propertyMethod = YES;
    self.selectIndex = selectIndex;
    [self.navView setSelected:_selectIndex animated:NO];
}

/// 刷新标签列表
/// @param titleArray 标签列表
- (void)reloadNavTitles:(NSArray *)titleArray {
    if (titleArray.count < self.nameArray.count) {
        for (NSInteger i = titleArray.count; i<_nameArray.count; i++) {
            NSString *key = [NSString stringWithFormat:@"%ld",(long)i];
            DLMenuContentView *contentView = self.viewDictionarys[key];
            if (contentView) {
                [contentView removeFromSuperview];
                [self.scrollView removeGestureRecognizer:contentView.scrollView.panGestureRecognizer];
                [self.viewDictionarys removeObjectForKey:key];
            }
        }
    }
    self.nameArray = titleArray;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*self.nameArray.count, 0);
    [self.navView reloadData:titleArray];
    self.propertyMethod = YES;
    [self.navView setSelected:_selectIndex animated:NO];
}

/**
 *  设置选中位置
 */
- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex != selectIndex) {
        DLMenuContentView *contentView = self.viewDictionarys[[NSString stringWithFormat:@"%ld",(long)self.currentIndex]];
        if (contentView) {
            [self.mainScrollView removeGestureRecognizer:contentView.scrollView.panGestureRecognizer];
        }
        self.currentIndex = selectIndex;
    }
    _selectIndex = selectIndex;
    if (!self.propertyMethod) {
        [self.navView setSelected:_selectIndex animated:!self.startTracking];
    }
    self.propertyMethod = NO;
}

/**
 *  选中内容获取选中页面
 */
- (void)getShowPage:(NSInteger)index{
    self.propertyMethod = YES;
    self.selectIndex = index;
    if (self.selectViewBlock) {
        NSString *tag = [NSString stringWithFormat:@"%ld",(long)index];
        DLMenuContentView *contentView = self.viewDictionarys[tag];
        if (!contentView) {
            UIView<DLMenuViewProtocol> *view = self.selectViewBlock(self.nameArray[index],index,CGRectMake(self.scrollView.frame.size.width*index, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height));
            if (view) {
                contentView = [DLMenuContentView new];
                [contentView addMenuView:view];
                if ([contentView.scrollView isKindOfClass:[UITableView class]] && contentView.scrollView.delegate != self) {
                    UITableView *tmpTableView = (UITableView *)contentView.scrollView;
                    tmpTableView.menuDelegate = tmpTableView.delegate;
                }
                contentView.scrollView.delegate = self;
                [self.scrollView addSubview:contentView];
                self.viewDictionarys[tag] = contentView;
            }
        }
        if (contentView) {
            [self.mainScrollView addGestureRecognizer:contentView.scrollView.panGestureRecognizer];
        }
    }
}

/**
 *  获取菜单栏，子类可重写
 */
- (DLMenuNavView *)fetchNavView{
    DLMenuNavView *navView = [[DLMenuNavView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.navHeight>0?self.navHeight:40)];
    return navView;
}

- (UIView *)fetchCurrentChildView{
    NSInteger index = self.scrollView.contentOffset.x/self.scrollView.frame.size.width;
    NSString *tag = [NSString stringWithFormat:@"%ld",(long)index];
    UIView *view = self.viewDictionarys[tag].targetView;
    return view;
}

- (UIView * __nullable)fetchChildViewAtIndex:(NSInteger)index {
    NSString *tag = [NSString stringWithFormat:@"%ld",(long)index];
    DLMenuContentView *view = self.viewDictionarys[tag];
    if (view) {
        return view.targetView;
    }
    return nil;
}

- (void)fixedWidthShowContent:(CGFloat)fixedWidth loc:(NSInteger)loc {
    __block CGFloat x = 0;
    [self.navView.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            CGRect rect = obj.frame;
            if (fixedWidth > 0) {
                rect.size.width = fixedWidth;
                rect.origin.x = x;
                obj.frame = rect;
            }
            x += rect.size.width;
        }
    }];
    CGRect rect = self.navView.frame;
    rect.size.width = x;
    if (loc == 0) {
        CGFloat xStart = (self.frame.size.width-x)/2.;
        rect.origin.x = xStart>0?xStart:0;
    } else if (loc == 1) {
        rect.origin.x = 0;
    }
    self.navView.frame = rect;
    self.navView.scrollView.frame = self.navView.bounds;
    self.navView.scrollView.contentSize = CGSizeMake(x, 0);
    //底部标识横线适配大小
    self.selectIndex = self.selectIndex;
}

#pragma mark - 设置button固定间距
- (void)fixedSpaceShowContent:(CGFloat)fixedSpace{
    __block CGFloat x = 15;
    [self.navView.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = obj;
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            CGRect rect = obj.frame;
            if (fixedSpace > 0) {
                rect.origin.x = x;
                rect.size.width -= 30;
                obj.frame = rect;
            }
            x += rect.size.width+fixedSpace;
        }
    }];
    self.navView.scrollView.frame = self.navView.bounds;
    self.navView.scrollView.contentSize = CGSizeMake(x, 0);
    //底部标识横线适配大小
    self.selectIndex = self.selectIndex;
}

- (void)resetSelectViewFrame:(CGRect)rect {
    self.navView.selectRect = rect;
    //底部标识横线适配大小
    self.selectIndex = self.selectIndex;
}

/// 重设frame
- (void)resetMenuScrollViewFrame:(CGRect)rect headerView:(UIView *)headerView nameArray:(NSArray *)nameArray selectedIndex:(NSInteger)selectedIndex {
    self.frame = rect;
    _mainScrollView.frame = self.bounds;
    _headerViewHeight = 0;
    if (_headerView.superview) {
        [_headerView removeFromSuperview];
    }
    _headerView = headerView;
    if (headerView) {
        [_mainScrollView addSubview:headerView];
        _mainScrollView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height+headerView.bounds.size.height);
        _headerViewHeight = headerView.bounds.size.height;
    }
    else {
        _mainScrollView.contentSize = self.bounds.size;
    }
    _navView.frame = CGRectMake(0, _headerViewHeight, self.frame.size.width, _navView.frame.size.height);
    _scrollView.frame = CGRectMake(0, CGRectGetMaxY(_navView.frame), self.frame.size.width, self.frame.size.height-CGRectGetHeight(_navView.frame));
    [_mainScrollView setContentOffset:CGPointZero];
    [self reloadData:nameArray selectIndex:selectedIndex];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (!self.startTracking) {
            self.startTracking = YES;
            NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
            self.selectIndex = index;
        }
    }
    else if (scrollView != self.mainScrollView) {
        _contentScrollViewOffset = scrollView.contentOffset;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (self.startTracking) {
            [self.navView moveLoc:scrollView.bounds.size.width movingLoc:scrollView.contentOffset.x];
        }
    }
    else if (scrollView != self.mainScrollView && _headerViewHeight>0) {
        CGFloat yOffset = scrollView.contentOffset.y-_contentScrollViewOffset.y;
        if (yOffset<0 && scrollView.contentOffset.y>=0) {
            _contentScrollViewOffset = scrollView.contentOffset;
            return;
        }
        
        if (yOffset>0 && scrollView.contentOffset.y <= 0) {
            _contentScrollViewOffset = scrollView.contentOffset;
            return;
        }
        
        _mainScrollView.contentOffset = CGPointMake(0, _mainScrollView.contentOffset.y + yOffset);
        if (_mainScrollYContentOffsetBlock) {
            _mainScrollYContentOffsetBlock(_mainScrollView.contentOffset.y);
        }
        if (_mainScrollView.contentOffset.y<0) {
            _mainScrollView.contentOffset = CGPointZero;
            _contentScrollViewOffset = scrollView.contentOffset;
        }
        else if (_mainScrollView.contentOffset.y<_headerViewHeight) {
            scrollView.contentOffset = _contentScrollViewOffset;
        }
        else {
            _mainScrollView.contentOffset = CGPointMake(0, _headerViewHeight);
            _contentScrollViewOffset = scrollView.contentOffset;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {
        if (self.startTracking) {
            NSInteger index = scrollView.contentOffset.x/scrollView.frame.size.width;
            self.selectIndex = index;
        }
        if (!scrollView.tracking) {
            self.startTracking = NO;
        }
    }
}

#pragma mark - 子视图UITableView的delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.menuDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [tableView.menuDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.menuDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [tableView.menuDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
