//
//  ASDKFinishAuthorizeRequest.h
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

@interface ASDKFinishAuthorizeRequest : ASDKAcquiringRequest

@property (nonatomic, copy) NSString *paymentId;
@property (nonatomic, copy) NSString *sendEmail;
@property (nonatomic, copy) NSString *cardData;
@property (nonatomic, copy) NSString *infoEmail;
@property (nonatomic, copy) NSString *encryptedPaymentData;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, copy) NSString *ipAddress;

- (ASDKFinishAuthorizeRequest *)initWithTerminalKey:(NSString *)terminalKey
                                          paymentId:(NSString *)paymentId
                                          sendEmail:(NSString *)sendEmail
                                           cardData:(NSString *)cardData
                                          infoEmail:(NSString *)infoEmail
											  token:(NSString *)token
							   encryptedPaymentData:(NSString *)encryptedPaymentData
											   data:(NSDictionary *)data
												 ip:(NSString * )ipAddress;

@end
