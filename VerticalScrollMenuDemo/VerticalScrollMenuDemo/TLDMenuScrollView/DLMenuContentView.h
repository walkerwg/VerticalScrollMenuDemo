//
//  DLMenuContentView.h
//  Teld
//
//  Created by yufeizhou on 2019/4/8.
//  Copyright © 2019 Teld. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLMenuViewProtocol.h"

@interface DLMenuContentView : UIView

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

/**
 内容视图
 */
@property (nonatomic, strong, readonly) UIView *targetView;

- (void)addMenuView:(UIView<DLMenuViewProtocol> *)view;

@end
