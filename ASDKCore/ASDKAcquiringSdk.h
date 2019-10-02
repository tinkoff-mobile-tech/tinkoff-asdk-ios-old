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
#import "ASDKCancelResponse.h"

#import "ASDKResponseAddCardInit.h"
#import "ASDKResponseAttachCard.h"
#import "ASDKResponseGetAddCardState.h"

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
@property (nonatomic, readwrite) BOOL testDomain;

@property (nonatomic, weak) id<ASDKAcquiringSdkLoggerDelegate> logger;

- (NSString *)domainPath;
- (NSString *)domainPath_v2;
- (SecKeyRef)publicKeyRef;
- (NSInteger)apiRequestsTimeoutInterval;

+ (ASDKAcquiringSdk *)acquiringSdkWithTerminalKey:(NSString *)terminalKey
										  payType:(NSString *)payType
                                         password:(NSString *)password
                              publicKeyDataSource:(id<ASDKAcquiringSdkPublicKeyDataSource>)publicKeyDataSource;

- (void)initWithAmount:(NSNumber *)amount
               orderId:(NSString *)orderId
           description:(NSString *)description
               payForm:(NSString *)payForm
           customerKey:(NSString *)customerKey
             recurrent:(BOOL)recurrent
 additionalPaymentData:(NSDictionary *)data
		   receiptData:(NSDictionary *)receiptData
			 shopsData:(NSArray *)shopsData
	 shopsReceiptsData:(NSArray *)shopsReceiptsData
			  location:(NSString *)location
               success:(void (^)(ASDKInitResponse *response))success
               failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)finishAuthorizeWithPaymentId:(NSString *)paymentId
				encryptedPaymentData:(NSString *)encryptedPaymentData
                            cardData:(NSString *)cardData
                           infoEmail:(NSString *)infoEmail
                             success:(void (^)(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                             failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)chargeWithPaymentId:(NSString *)paymentId
                   rebillId:(NSNumber *)rebillId
                    success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
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

- (void)rejectTrancastionWithPaymentId:(NSString *)paymentId
							   success:(void (^)(ASDKCancelResponse *response))success
							   failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)initAttachCardWithCheckType:(NSString *)cardCheckType
						customerKey:(NSString *)customerKey
							success:(void (^)(ASDKResponseAddCardInit *response))success
							failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)finishAttachCardWithCardData:(NSString *)cardData aditionalInfo:(NSDictionary *)data requestKey:(NSString *)requestKey
							 success:(void (^)(ASDKThreeDsData *data, ASDKResponseAttachCard *result, ASDKPaymentStatus status))success
							 failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)getStateAttachCardWithRequestKey:(NSString *)requestKey
								 success:(void (^)(ASDKResponseGetAddCardState *response))success
								 failure:(void (^)(ASDKAcquringSdkError *error))failure;

- (void)getStateSubmitRandomAmount:(NSNumber *)amount
						requestKey:(NSString *)requestKey
						   success:(void (^)(ASDKResponseGetAddCardState *response))success
						   failure:(void (^)(ASDKAcquringSdkError *error))failure;

@end
