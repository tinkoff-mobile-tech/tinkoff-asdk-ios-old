//
//  ASDKPaymentViewController.h
//  ASDKUI
//
// Copyright (c) 2016 TCS Bank
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import <ASDKCore/ASDKCore.h>
#import "ASDKBaseTableViewController.h"
#import "ASDKCardInputTableViewCell.h"

@class ASDKAcquringApiError;

@interface ASDKPaymentFormViewController : ASDKBaseTableViewController <UIAdaptivePresentationControllerDelegate>

@property (nonatomic, strong) ASDKAcquiringSdk *acquiringSdk;

- (instancetype)initWithAmount:(NSNumber *)amount
                       orderId:(NSString *)orderId
                         title:(NSString *)title
                   description:(NSString *)description
                        cardId:(NSString *)cardId
                         email:(NSString *)email
                   customerKey:(NSString *)customerKey
					 recurrent:(BOOL)recurrent
					makeCharge:(BOOL)makeCharge
		 additionalPaymentData:(NSDictionary *)data
				   receiptData:(NSDictionary *)receiptData
					 shopsData:(NSArray *)shopsData
			 shopsReceiptsData:(NSArray *)shopsReceiptsData
                       success:(void (^)(ASDKPaymentInfo *paymentInfo))success
                     cancelled:(void (^)(void))cancelled
                         error:(void (^)(ASDKAcquringSdkError *error))error;

@property (nonatomic, strong) NSString *paymentId;
//
- (void)needSetupCardRequisitesCellForCVC;
- (void)setChargeError:(BOOL)value;
- (void)setChargeErrorPaymentId:(NSString *)error;

@end
