//
//  ASDKInitRequestBuilder.h
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

#import "ASDKRequestBuilder.h"

#import "ASDKInitRequest.h"

@interface ASDKInitRequestBuilder : ASDKRequestBuilder

+ (ASDKInitRequestBuilder *)builderWithAmount:(NSNumber *)amount
                                      orderId:(NSString *)orderId
								  description:(NSString *)description
                                      payForm:(NSString *)payForm
									  payType:(NSString *)payType
                                  customerKey:(NSString *)customerKey
                                    recurrent:(BOOL)recurrent
                                  terminalKey:(NSString *)terminalKey
                                     password:(NSString *)password
						additionalPaymentData:(NSDictionary *)data
								  receiptData:(NSDictionary *)receiptData
									shopsData:(NSArray *)shopsData
							shopsReceiptsData:(NSArray *)shopsReceiptsData
									 location:(NSString *)location;

@end
