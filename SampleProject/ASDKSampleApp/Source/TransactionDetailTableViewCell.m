//
//  TransactionDetailTableViewCell.m
//  ASDKDevelopSampleProject
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 АО «Тинькофф Банк». All rights reserved.
//

#import "TransactionDetailTableViewCell.h"

@interface TransactionDetailTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonRefund;
@property (weak, nonatomic) IBOutlet UIButton *buttonRecurring;
@property (weak, nonatomic) IBOutlet UIButton *buttonApplePay;

@end

@implementation TransactionDetailTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

	//
}

- (void)setStatus:(NSString *)status
{
	[self.labelStatus setText:status];
}

- (void)setDescription:(NSString *)description
{
	[self.labelDescription setText:description];
}

- (void)setPaymentId:(NSString *)paymentId
{
	self.paymentId = paymentId;
}

- (void)setHiddenRefund:(BOOL)hidden
{
	[self.buttonRefund setHidden:hidden];
}

- (void)setEnabledRefund:(BOOL)enabled
{
	[self.buttonRefund setEnabled:enabled];
}

- (void)setHiddenRecurring:(BOOL)hidden
{
	[self.buttonRecurring setHidden:hidden];
}

- (void)addButtonApplePayTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.buttonApplePay removeTarget:target action:nil forControlEvents:controlEvents];
	[self.buttonApplePay addTarget:target action:action forControlEvents:controlEvents];
}

- (void)addButtonRefundTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.buttonRefund removeTarget:target action:nil forControlEvents:controlEvents];
	[self.buttonRefund addTarget:target action:action forControlEvents:controlEvents];
}

- (void)addButtonRecurringTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.buttonRecurring removeTarget:target action:nil forControlEvents:controlEvents];
	[self.buttonRecurring addTarget:target action:action forControlEvents:controlEvents];
}

@end
