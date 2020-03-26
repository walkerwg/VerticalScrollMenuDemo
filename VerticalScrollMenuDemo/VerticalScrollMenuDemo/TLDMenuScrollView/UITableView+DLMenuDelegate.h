//
//  UITableView+DLMenuDelegate.h
//  Teld
//
//  Created by yufeizhou on 2019/4/8.
//  Copyright © 2019 Teld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DLMenuDelegate)

/**
 值为原来的delegate
 */
@property (nonatomic, assign) id<UITableViewDelegate> menuDelegate;

@end
