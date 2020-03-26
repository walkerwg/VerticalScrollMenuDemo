//
//  UITableView+DLMenuDelegate.m
//  Teld
//
//  Created by yufeizhou on 2019/4/8.
//  Copyright © 2019 Teld. All rights reserved.
//

#import "UITableView+DLMenuDelegate.h"
#import <objc/runtime.h>

@implementation UITableView (DLMenuDelegate)

static const char DLMenuDelegateKey = '\0';
- (void)setMenuDelegate:(id<UITableViewDelegate>)menuDelegate {
    objc_setAssociatedObject(self, &DLMenuDelegateKey, menuDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<UITableViewDelegate>)menuDelegate {
    return objc_getAssociatedObject(self, &DLMenuDelegateKey);
}

@end
