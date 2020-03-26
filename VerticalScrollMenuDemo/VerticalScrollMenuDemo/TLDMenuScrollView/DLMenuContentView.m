//
//  DLMenuContentView.m
//  Teld
//
//  Created by yufeizhou on 2019/4/8.
//  Copyright © 2019 Teld. All rights reserved.
//

#import "DLMenuContentView.h"

@implementation DLMenuContentView

- (void)addMenuView:(UIView<DLMenuViewProtocol> *)view {
    _targetView = view;
    self.frame = view.frame;
    if ([view respondsToSelector:@selector(mainScrollViewOfMenuView)]) {
        _scrollView = [view mainScrollViewOfMenuView];
    }
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:view.bounds];
        _scrollView.contentSize = view.bounds.size;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.alwaysBounceHorizontal = NO;
        view.frame = view.bounds;
        [_scrollView addSubview:view];
        [self addSubview:_scrollView];
    }
    else {
        view.frame = view.bounds;
        [self addSubview:view];
    }
}

@end
