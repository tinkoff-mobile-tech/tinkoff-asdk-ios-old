//
//  ASDKInitRequest.h
//  ASDKCore
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



#import "ASDKAcquiringRequest.h"

@interface ASDKInitRequest : ASDKAcquiringRequest

@property (nonatomic, copy) NSString *payType;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *customerKey;
@property (nonatomic, copy) NSString *requestDescription;
@property (nonatomic, copy) NSString *payForm;
@property (nonatomic) BOOL recurrent;
@property (nonatomic, strong) NSDictionary *additionalPaymentData;
@property (nonatomic, strong) NSDictionary *receiptData;
@property (nonatomic, strong) NSArray *shopsData;
@property (nonatomic, strong) NSArray *shopsReceiptsData;
@property (nonatomic, copy) NSString *location;

- (ASDKInitRequest *)initWithTerminalKey:(NSString *)terminalKey
                                  amount:(NSString *)amount
                                 orderId:(NSString *)orderId
                             description:(NSString *)description
                                   token:(NSString *)token
                                 payForm:(NSString *)payForm
								 payType:(NSString *)payType
                             customerKey:(NSString *)customerKey
                               recurrent:(BOOL)recurrent
				   additionalPaymentData:(NSDictionary *)data
							 receiptData:(NSDictionary *)receiptData
							   shopsData:(NSArray *)shopsData
					   shopsReceiptsData:(NSArray *)shopsReceiptsData
								location:(NSString *)location;

@end
