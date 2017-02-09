//
//  TransactionHistoryModelController.h
//  ASDKDevelopSampleProject
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 АО «Тинькофф Банк». All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionHistoryModelController : NSObject

+ (instancetype)sharedInstance;

- (void)updateTransaction:(NSDictionary *)info;
- (void)addTransaction:(NSDictionary *)info;
- (NSArray *)transactions;

- (NSNumber *)rebillId;
- (void)saveRebillId:(NSNumber *)rebillId;

@end
