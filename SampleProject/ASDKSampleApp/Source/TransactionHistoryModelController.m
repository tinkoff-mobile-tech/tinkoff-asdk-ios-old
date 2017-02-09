//
//  TransactionHistoryModelController.m
//  ASDKDevelopSampleProject
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 АО «Тинькофф Банк». All rights reserved.
//

#import "TransactionHistoryModelController.h"

#define kTransactionHistory @"TransactionHistory"
#define kTransactionRebillId @"kTransactionRebillId"

@interface TransactionHistoryModelController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation TransactionHistoryModelController

+ (instancetype)sharedInstance
{
	static dispatch_once_t onceToken = 0;
	__strong static id _sharedObjectTransactionHistory = nil;
	dispatch_once(&onceToken,
				  ^{
					  _sharedObjectTransactionHistory = [[self alloc] init];
				  });
	
	return _sharedObjectTransactionHistory;
}

- (instancetype)init
{
	if (self = [super init])
	{
		_dataSource = [NSMutableArray new];
		
		NSArray *dataSource = [[NSUserDefaults standardUserDefaults] objectForKey:kTransactionHistory];
		if (dataSource && [dataSource isKindOfClass:[NSArray class]])
		{
			[_dataSource addObjectsFromArray:dataSource];
		}
	}
	
	return self;
}

- (void)updateTransaction:(NSDictionary *)info
{
	for (NSUInteger index = 0; index < [self.dataSource count]; index++)
	{
		NSDictionary *transaction = [self.dataSource objectAtIndex:index];
		
		if ([[info objectForKey:@"paymentId"] isEqualToString:[transaction objectForKey:@"paymentId"]])
		{
			[self.dataSource replaceObjectAtIndex:index withObject:info];
			[self saveTransactions];
			break;
		}
	}
}

- (void)addTransaction:(NSDictionary *)info
{
	[self.dataSource addObject:info];
	[self saveTransactions];
}

- (NSArray *)transactions
{
	return [self.dataSource copy];
}

- (void)saveTransactions
{
	[[NSUserDefaults standardUserDefaults] setObject:[self.dataSource copy] forKey:kTransactionHistory];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber *)rebillId
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:kTransactionRebillId];
}

- (void)saveRebillId:(NSNumber *)rebillId
{
	[[NSUserDefaults standardUserDefaults] setObject:rebillId forKey:kTransactionRebillId];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
