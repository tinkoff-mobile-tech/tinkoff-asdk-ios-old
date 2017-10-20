//
//  ItemsListTableViewController.m
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "ItemsListTableViewController.h"
#import "BookItemCell.h"

#import "DetailInfoTableViewController.h"

#import "ShopCartTableViewController.h"

#import "AboutViewController.h"
#import "SettingsViewController.h"
#import "TransactionHistoryViewController.h"

#import "PayController.h"

@interface ItemsListTableViewController ()

@property (nonatomic, strong) NSArray *itemsArray;
@property (nonatomic, strong) BookItemCell *sizingCell;

@property (strong, nonatomic) NSMutableArray *history;

@end

@implementation ItemsListTableViewController

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super init];
    
    if (self)
    {
        _itemsArray = items;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self setTitle:NSLocalizedString(@"OnlineShop", @"Интернет магазин")];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookItemCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([BookItemCell class])];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UIBarButtonItem *shopCartButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Bag", @"Корзина")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(openShopCart:)];
	
	UIBarButtonItem *shopHistoryButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"History", @"История")
																	   style:UIBarButtonItemStylePlain
																	  target:self
																	  action:@selector(openHistory:)];

	
    [self.navigationItem setRightBarButtonItems:@[shopCartButton, shopHistoryButton]];
	
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	
	UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showSettings)];
    
    [self.navigationItem setLeftBarButtonItems:@[infoBarButton, settingsBarButton]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDetailsInfoNotification:) name:kDetailsInfoNotification object:nil];
}

- (BookItemCell *)sizingCell
{
    if (!_sizingCell)
    {
        _sizingCell = [BookItemCell cell];
    }
    
    return _sizingCell;
}

- (IBAction)openShopCart:(id)sender
{
    ShopCartTableViewController *shopCartController = [[ShopCartTableViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shopCartController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)openHistory:(id)sender
{
	TransactionHistoryViewController *viewController = [[TransactionHistoryViewController alloc] initWithNibName:@"TransactionHistoryViewController" bundle:[NSBundle mainBundle]];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)showInfo
{
    AboutViewController *vc = [[AboutViewController alloc] init];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nc
                       animated:YES
                     completion:nil];
}

- (void)showSettings
{
	[self presentViewController:[[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped]]
					   animated:YES
					 completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _itemsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookItemCell *cell = [self sizingCell];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    [cell layoutIfNeeded];
    
    CGFloat height = MIN(484, [cell cellHeightWithWidth:self.view.frame.size.width-30]);
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([BookItemCell class]) forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[BookItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([BookItemCell class])];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(BookItemCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    BookItem *currentItem = _itemsArray[indexPath.row];
    
    [cell setBookItem:currentItem];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}


- (void)handleDetailsInfoNotification:(NSNotification *)notification
{
    BookItem *item = notification.userInfo[@"bookItem"];
    DetailInfoTableViewController *detailInfoController = [[DetailInfoTableViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:detailInfoController animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
