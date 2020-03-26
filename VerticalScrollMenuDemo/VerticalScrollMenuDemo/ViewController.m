//
//  ViewController.m
//  VerticalScrollMenuDemo
//
//  Created by wg on 2020/3/26.
//  Copyright © 2020 wg. All rights reserved.
//

#import "ViewController.h"
#import "DLMenuNavView.h"

#define kMAIN_SCREEN_HEIGHT      [[UIScreen mainScreen] bounds].size.height
#define kMAIN_SCREEN_WIDTH       ([[UIScreen mainScreen] bounds].size.width)

#define kMenuNavViewHeight   34.0

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) DLMenuNavView *menuNavView; //tab菜单
@property (nonatomic, strong) UIView * menuNavContainerView; //tab菜单的容器

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"客服中心";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setFakeNaViBar];
    [self prepareTableView];
    [self setHeaderView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];

}
- (void)setFakeNaViBar {
    
    // 实际项目一般都是自带了naviBar，无需添加，此处是为了方便
    UIView *naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, 100)];
    naviBar.backgroundColor = [UIColor systemPinkColor];
    [self.view addSubview:naviBar];
}

- (void)prepareTableView {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 84, kMAIN_SCREEN_WIDTH, kMAIN_SCREEN_HEIGHT - 84) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 0; //这行及其关键
    self.tableView.dataSource = self;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.tableView];
}


/**
 重载头部view
 */
- (void)setHeaderView {
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, 100)];
    header.backgroundColor = [UIColor systemBackgroundColor];
    
    // 常见问题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, kMAIN_SCREEN_WIDTH, 55)];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.text = @"常见问题";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:titleLabel];
    self.tableView.tableHeaderView = header;
}


- (void)reloadData {
    
    [self.tableView reloadData];
    //每次刷新数据都要调用一次
    [self setTableBottomInset];
}

- (void)setTableBottomInset {
    
    //次方法实际情况应该在返回数据reload data之后掉，等tableview布局好了的才可以
    //获取最后一组的高度，我这因为写死了7组数据所以写6，实际情况可以根据请求数据的组数来确定
    CGFloat lastSectionHeight = [self.tableView rectForSection:6].size.height;
    CGFloat insetHeight = self.tableView.frame.size.height - lastSectionHeight;
    if (insetHeight > 0) {
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, insetHeight, 0)];
        
    }
}

#pragma mark - tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"这里是cell的内容，cell可以自定义，cell的正常设置即可";
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 0 ) {
        //第一组不需要展示副标题，直接展示tab
        self.menuNavContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, kMenuNavViewHeight)];
        if (!self.menuNavView.superview) {
            [self.menuNavContainerView addSubview:self.menuNavView];

        }
        return self.menuNavContainerView;
    }
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, 39)];
    header.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kMAIN_SCREEN_WIDTH - 30, 39)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"副标题";
    [header addSubview:label];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, 39 - 0.5, kMAIN_SCREEN_WIDTH - 15, 0.5)];
    line.backgroundColor = [UIColor lightTextColor];
    [header addSubview:line];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //cell的高度可以自适应，此处为了方便写死了
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kMenuNavViewHeight;
    }
    return 39;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;

    if (offsetY > self.tableView.tableHeaderView.frame.size.height) {
        //置顶tab
        if (self.menuNavView.superview != self.view) {
            self.menuNavView.frame = CGRectMake(0, 84, kMAIN_SCREEN_WIDTH, kMenuNavViewHeight);
            [self.view addSubview:self.menuNavView];
        }
    } else {
        if (self.menuNavView.superview != self.menuNavContainerView) {
            self.menuNavView.frame = CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, kMenuNavViewHeight);
            [self.menuNavContainerView addSubview:self.menuNavView];
        }
    }
    if (!(scrollView.isTracking || scrollView.isDecelerating)) {
        //不是用户滚动的，不做处理
        return;
    }
    //+1获取菜单下面一点的rect
    CGRect topRect = CGRectMake(0, offsetY + kMenuNavViewHeight + 1, kMAIN_SCREEN_WIDTH, 1);
    NSIndexPath *path = [self.tableView indexPathsForRowsInRect:topRect].firstObject;
    if ( path && self.menuNavView.selectIndex != path.section ) {
        [self.menuNavView moveBottomLineToIndex:path.section animated:YES];
    }
    //滑倒最后一组卡住不动
    if ( offsetY > scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.size.height - kMenuNavViewHeight) {
        offsetY =  scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.size.height - kMenuNavViewHeight;
        [scrollView setContentOffset:CGPointMake(0, offsetY) animated:NO];
    }
}


#pragma mark - 常见问题相关

- (DLMenuNavView *)menuNavView {
    
    if (_menuNavView == nil) {
        NSArray *titlesArray = @[@"swift",@"python-6666",@"shell",@"objc",@"php",@"java",@"小程序"];
        _menuNavView = [[DLMenuNavView alloc] initWithFrame:CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, kMenuNavViewHeight) menuNames:titlesArray normalColor:[UIColor blackColor] selectedColor:[UIColor blueColor] font:[UIFont systemFontOfSize:14] space:15 showLoc:^(NSInteger index) {
            CGFloat sectionHeight = [self.tableView rectForSection:index].origin.y;
            if (index == 0) {
                [self.tableView setContentOffset:CGPointMake(0, sectionHeight) animated:YES];
            } else {
                [self.tableView setContentOffset:CGPointMake(0, sectionHeight - kMenuNavViewHeight) animated:YES];

            }
        }];
        //展示右边蒙版
        [_menuNavView showMaskView];
        _menuNavView.backgroundColor = [UIColor whiteColor];
        _menuNavView.selectView.hidden = NO;
        //光标初始位置
        [_menuNavView moveBottomLineToIndex:0 animated:NO];
    }
    
    return  _menuNavView;
}

//菊花
- (UIView *)showIndicateActivitor {
    
    UIView * activitorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, 300)];
    activitorView.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *activitor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    activitor.frame = CGRectMake((activitorView.frame.size.width - 40)/2.0, 50, 40, 40);
    [activitorView addSubview:activitor];
    [activitor startAnimating];
    return activitorView;
}

//空页面占位
- (UIView *)showNoDataView {
    
    UIView * noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMAIN_SCREEN_WIDTH, 300)];
    noDataView.backgroundColor = [UIColor whiteColor];
        
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, noDataView.frame.size.width, 20)];
    label.text = @"数据加载失败";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    [noDataView addSubview:label];
    return noDataView;
}


@end
