//
//  ASDKAcquiringSdk.h
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

#import <Foundation/Foundation.h>

#import "ASDKAcquringSdkError.h"

#import "ASDKInitResponse.h"
#import "ASDKFinishAuthorizeResponse.h"
#import "ASDKChargeResponse.h"
#import "ASDKGetStateResponse.h"
#import "ASDKGetCardListResponse.h"
#import "ASDKRemoveCardResponse.h"

#import "ASDKCardData.h"
#import "ASDKCard.h"

@protocol ASDKAcquiringSdkLoggerDelegate <NSObject>

- (void)print:(NSString *)logString;

@end

@protocol ASDKAcquiringSdkPublicKeyDataSource <NSObject>

- (SecKeyRef)publicKey;

@end


@interface ASDKAcquiringSdk : NSObject

@property (nonatomic, readwrite) BOOL debug;

@property (nonatomic, weak) id<ASDKAcquiringSdkLoggerDelegate> logger;

- (NSString *)domainPath;
- (SecKeyRef)publicKeyRef;

+ (ASDKAcquiringSdk *)acquiringSdkWithTerminalKey:(NSString *)terminalKey
                                         password:(NSString *)password
                              publicKeyDataSource:(id<ASDKAcquiringSdkPublicKeyDataSource>)publicKeyDataSource;

//+ (ASDKAcquiringSdk *)acquiringSdkWithTerminalKey:(NSString *)terminalKey
//                                         password:(NSString *)password
//                                        publicKey:(SecKeyRef)publicKey;


- (void)initWithAmount:(NSNumber *)amount
               orderId:(NSString *)orderId
           description:(NSString *)description
               payForm:(NSString *)payForm
           customerKey:(NSString *)customerKey
             recurrent:(BOOL)recurrent
               success:(void (^)(ASDKInitResponse *response))success
               failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)finishAuthorizeWithPaymentId:(NSString *)paymentId
                            cardData:(NSString *)cardData
                           infoEmail:(NSString *)infoEmail
                             success:(void (^)(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                             failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)chargeWithPaymentId:(NSString *)paymentId
                   rebillId:(NSNumber *)rebillId
                    success:(void (^)(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo))success
                    failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)getStateWithPaymentId:(NSString *)paymentId
                      success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                      failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)getCardListWithCustomerKey:(NSString *)customerKey
                           success:(void (^)(ASDKGetCardListResponse *response))success
                           failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)removeCardWithCustomerKey:(NSString *)customerKey
                           cardId:(NSNumber *)cardId
                          success:(void (^)(ASDKRemoveCardResponse *response))success
                          failure:(void (^)(ASDKAcquringSdkError *error))failure;

//- (void)getUrlWithSuccess:(void (^)(NSURL *url))success
//                  failure:(void (^)(ASDKAcquringSdkError *error))failure;


@end
