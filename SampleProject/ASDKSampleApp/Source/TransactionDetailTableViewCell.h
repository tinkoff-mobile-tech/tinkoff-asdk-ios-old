//
//  TransactionDetailTableViewCell.h
//  ASDKDevelopSampleProject
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 АО «Тинькофф Банк». All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionDetailTableViewCell : UITableViewCell

- (void)setStatus:(NSString *)status;
- (void)setDescription:(NSString *)description;
//- (void)setPaymentId:(NSString *)paymentId;

- (void)setHiddenRefund:(BOOL)hidden;
- (void)setEnabledRefund:(BOOL)enabled;
//- (void)setHiddenRecurring:(BOOL)hidden;

//- (void)addButtonApplePayTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)addButtonRefundTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
//- (void)addButtonRecurringTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
