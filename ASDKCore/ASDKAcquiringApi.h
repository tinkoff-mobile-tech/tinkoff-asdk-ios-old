//
//  ASDKAcquiringApi.h
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

#import "ASDKAcquiringRequest.h"
#import "ASDKAcquiringResponse.h"

#import "ASDKInitRequest.h"
#import "ASDKInitResponse.h"

#import "ASDKFinishAuthorizeRequest.h"
#import "ASDKFinishAuthorizeResponse.h"

#import "ASDKChargeRequest.h"
#import "ASDKChargeResponse.h"

#import "ASDKGetStateRequest.h"
#import "ASDKGetStateResponse.h"

#import "ASDKGetCardListRequest.h"
#import "ASDKGetCardListResponse.h"

#import "ASDKRemoveCardRequest.h"
#import "ASDKRemoveCardResponse.h"

#import "ASDKAcquringApiError.h"

#import "ASDKThreeDsData.h"
#import "ASDKPaymentInfo.h"

#import "ASDKCancelRequest.h"
#import "ASDKCancelResponse.h"

#import "ASDKRequestAddCardInit.h"
#import "ASDKResponseAddCardInit.h"

#import "ASDKRequestAttachCard.h"
#import "ASDKResponseAttachCard.h"

#import "ASDKRequestGetAttachCardState.h"
#import "ASDKResponseGetAddCardState.h"

#import "ASDKRequestSubmitRandomAmount.h"

@protocol ASDKAcquiringApiLoggerDelegate <NSObject>

- (void)print:(NSString *)logString;

@end

@interface ASDKAcquiringApi : NSObject

@property (nonatomic,weak) id<ASDKAcquiringApiLoggerDelegate> acquiringApiLoggerDelegate;

@property (nonatomic, strong) NSString *domainPath;
@property (nonatomic, strong) NSString *domainPath_v2;

@property (nonatomic, assign) NSInteger requestTimeoutInterval;

+ (ASDKAcquiringApi *)acquiringApiWithDomainPath:(NSString *)domainPath domainPath_v2:(NSString *)domainPath_v2;

- (void)initWithRequest:(ASDKInitRequest *)request
                success:(void (^)(ASDKInitResponse *response))success
                failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)finishAuthorizeWithRequest:(ASDKFinishAuthorizeRequest *)request
                           success:(void (^)(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                           failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)chargeWithRequest:(ASDKChargeRequest *)request
                             success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                             failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)getStateWithRequest:(ASDKGetStateRequest *)request
                    success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                    failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)getCardListWithRequest:(ASDKGetCardListRequest *)request
                       success:(void (^)(ASDKGetCardListResponse *response))success
                       failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)removeCardWithRequest:(ASDKRemoveCardRequest *)request
                      success:(void (^)(ASDKRemoveCardResponse *response))success
                      failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)cancelWithRequest:(ASDKCancelRequest *)request
				  success:(void (^)(ASDKCancelResponse *data))success
				  failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)initAddCardWithRequest:(ASDKRequestAddCardInit *)request
					   success:(void (^)(ASDKResponseAddCardInit *info))success
					   failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)finishAddCardRequest:(ASDKRequestAttachCard *)request
					 success:(void (^)(ASDKThreeDsData *data, ASDKResponseAttachCard *result, ASDKPaymentStatus status))success
					 failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)getStateAttachCardRequest:(ASDKRequestGetAttachCardState *)request
					 success:(void (^)(ASDKResponseGetAddCardState *response))success
					 failure:(void (^)(ASDKAcquringApiError *error))failure;

- (void)getStateSubmitRandomAmount:(ASDKRequestSubmitRandomAmount *)request
						   success:(void (^)(ASDKResponseGetAddCardState *response))success
						   failure:(void (^)(ASDKAcquringApiError *error))failure;

@end
