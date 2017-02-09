//
//  TransactionHistoryViewController.m
//  ASDKDevelopSampleProject
//
//  Created by v.budnikov on 06.02.17.
//  Copyright © 2017 АО «Тинькофф Банк». All rights reserved.
//

#import "TransactionHistoryViewController.h"
#import "TransactionDetailTableViewCell.h"
#import "PayController.h"
#import "UITableViewHelpers.h"
#import "TransactionHistoryModelController.h"
#import "ASDKLoaderViewController.h"

@interface TransactionHistoryViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *transactions;

@end

@implementation TransactionHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setTitle:NSLocalizedString(@"Purchasehistory", @"История покупок")];
	
	[UITableViewHelpers registerCellNib:NSStringFromClass([TransactionDetailTableViewCell class]) forTable:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.transactions = [[TransactionHistoryModelController sharedInstance] transactions];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.transactions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	TransactionDetailTableViewCell *cell = (TransactionDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TransactionDetailTableViewCell class])];
	
	NSDictionary *info = [self.transactions objectAtIndex:indexPath.row];
	
	[cell setDescription:[NSString stringWithFormat:@"RUB%@, %@", [info objectForKey:@"summ"], [info objectForKey:@"description"]]];
	
	[cell setStatus:[NSString stringWithFormat:@"Status: %@", [info objectForKey:kASDKStatus]]];
	[cell addButtonRefundTarget:self action:@selector(buttonActionRefund:) forControlEvents:UIControlEventTouchUpInside];
	
	ASDKAcquiringResponse *infoStatus = [[ASDKAcquiringResponse alloc] initWithDictionary:info];
	[self checkStatus:cell status:infoStatus.status];
	
	NSString *paymentId = [info objectForKey:@"paymentId"];
	
	[PayController checkStatusTransaction:paymentId fromViewController:self success:^(ASDKPaymentStatus status) {
		if ([[ASDKAcquiringResponse localizedStatus:status] isEqualToString:[info objectForKey:kASDKStatus]] == NO)
		{
			[cell setStatus:[NSString stringWithFormat:@"Status: %@", [ASDKAcquiringResponse localizedStatus:status]]];
			NSMutableDictionary *infoNew = [NSMutableDictionary dictionaryWithDictionary:info];
			[infoNew setObject:[ASDKAcquiringResponse localizedStatus:status] forKey:kASDKStatus];
			[[TransactionHistoryModelController sharedInstance] updateTransaction:[infoNew copy]];
			[self checkStatus:cell status:infoStatus.status];
		}
	} error:^(ASDKAcquringSdkError *error) {
		NSLog(@"%@", error.localizedDescription);
	}];

	return cell;
}

- (void)checkStatus:(TransactionDetailTableViewCell *)cell status:(ASDKPaymentStatus)status
{
	if ([[NSSet setWithObjects:@(ASDKPaymentStatus_NEW), @(ASDKPaymentStatus_AUTHORIZED), @(ASDKPaymentStatus_CONFIRMED), nil] containsObject:@(status)])
	{
		[cell setEnabledRefund:YES];
	}
	else
	{
		[cell setEnabledRefund:NO];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 72.0;
}

#pragma mark button action

- (void)buttonActionRefund:(UIButton *)button
{
	UITableViewCell *cell = [UITableViewHelpers tableViewCellBySubView:button];
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	
	NSDictionary *info = [self.transactions objectAtIndex:indexPath.row];
	NSString *paymentId = [info objectForKey:@"paymentId"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
	
	[PayController refundTransaction:paymentId fromViewController:self success:^{
		[PayController checkStatusTransaction:paymentId fromViewController:self success:^(ASDKPaymentStatus status) {
			NSMutableDictionary *infoNew = [NSMutableDictionary dictionaryWithDictionary:info];
			[infoNew setObject:[ASDKAcquiringResponse localizedStatus:status] forKey:kASDKStatus];
			[[TransactionHistoryModelController sharedInstance] updateTransaction:[infoNew copy]];
			self.transactions = [[TransactionHistoryModelController sharedInstance] transactions];
			[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
			[self.tableView reloadData];
		} error:^(ASDKAcquringSdkError *error) {
			[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
		}];
	} error:^(ASDKAcquringSdkError *error) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
	}];
}

@end
