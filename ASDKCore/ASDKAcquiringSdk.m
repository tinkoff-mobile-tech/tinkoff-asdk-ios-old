//
//  ASDKAcquiringSdk.m
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

#import "ASDKAcquiringSdk.h"
#import "ASDKAcquiringApi.h"
#import "ASDKAcquringApiError.h"

#import "ASDKInitRequestBuilder.h"
#import "ASDKFinishAuthorizeRequestBuilder.h"
#import "ASDKChargeRequestBuilder.h"
#import "ASDKGetStateRequestBuilder.h"
#import "ASDKGetCardListRequestBuilder.h"
#import "ASDKRemoveCardRequestBuilder.h"
#import "ASDKCancelRequestBuilder.h"
#import "ASDKRequestBuilderAddCardInit.h"
#import "ASDKRequestBuilderGetAttachCardState.h"
#import "ASDKRequestBuilderAttachCard.h"

#import "ASDKRequestBuilderSubmitRandomAmount.h"
#import "ASDKRequestSubmitRandomAmount.h"

@interface ASDKAcquiringSdk () <ASDKAcquiringApiLoggerDelegate>

@property (nonatomic, strong) ASDKAcquiringApi *acquiringApi;
@property (nonatomic, strong) NSString *payType;
@property (nonatomic, strong) NSString *terminalKey;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) id<ASDKAcquiringSdkPublicKeyDataSource> publicKeyDataSource;

@end


@implementation ASDKAcquiringSdk

+ (ASDKAcquiringSdk *)acquiringSdkWithTerminalKey:(NSString *)terminalKey
										  payType:(NSString *)payType
                                         password:(NSString *)password
                              publicKeyDataSource:(id<ASDKAcquiringSdkPublicKeyDataSource>)publicKeyDataSource
{
    ASDKAcquiringSdk *acquiringSdk = [[ASDKAcquiringSdk alloc] init];
    
    if (acquiringSdk)
    {
        acquiringSdk.terminalKey = terminalKey;
		acquiringSdk.payType = payType;
        acquiringSdk.password = password;
        acquiringSdk.publicKeyDataSource = publicKeyDataSource;
		acquiringSdk.acquiringApi = [ASDKAcquiringApi acquiringApiWithDomainPath:[acquiringSdk domainPath] domainPath_v2:[acquiringSdk domainPath_v2]];
    }
    
    return acquiringSdk;
}


- (void)setLogger:(id<ASDKAcquiringSdkLoggerDelegate>)logger
{
    _logger = logger;
    
    self.acquiringApi.acquiringApiLoggerDelegate = self;
}

- (NSString *)domainPath
{
    return [self testDomain] ? kASDKTestDomainName : kASDKDomainName;
}

- (NSString *)domainPath_v2
{
	return [self testDomain] ? kASDKTestDomainName_v2 : kASDKDomainName_v2;
}

- (SecKeyRef)publicKeyRef
{
    id<ASDKAcquiringSdkPublicKeyDataSource> publicKeyDataSource = self.publicKeyDataSource;
    
    SecKeyRef publicKeyRef = [publicKeyDataSource publicKey];
    
    return publicKeyRef;
}

- (void)setTestDomain:(BOOL)value
{
	_testDomain = value;
	
	self.acquiringApi.domainPath = [self domainPath];
	self.acquiringApi.domainPath_v2 = [self domainPath_v2];
}

- (NSInteger)apiRequestsTimeoutInterval
{
	return self.acquiringApi.requestTimeoutInterval;
}

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
               failure:(void (^)(ASDKAcquringSdkError *error))failure
{
    ASDKAcquringSdkError *buildError;
    
    ASDKInitRequestBuilder *builder = [ASDKInitRequestBuilder builderWithAmount:amount
																		orderId:orderId
																	description:description
																		payForm:payForm
																		payType:self.payType
																	customerKey:customerKey
																	  recurrent:recurrent
																	terminalKey:self.terminalKey
																	   password:self.password
														  additionalPaymentData:data
																	receiptData:receiptData
																	  shopsData:shopsData
															  shopsReceiptsData:shopsReceiptsData
																	   location:location];
    
    ASDKInitRequest *request = (ASDKInitRequest *)[builder buildError:&buildError];
    
    if (buildError)
    {
        failure(buildError);
    }
    else
    {
        [self.acquiringApi initWithRequest:request
                                  success:^(ASDKInitResponse *response)
        {
            success(response);
        }
                                  failure:^(ASDKAcquringApiError *error)
        {
            failure(error);
        }];
    }
}

- (void)finishAuthorizeWithPaymentId:(NSString *)paymentId
				encryptedPaymentData:(NSString *)encryptedPaymentData
                            cardData:(NSString *)cardData
                           infoEmail:(NSString *)infoEmail
                             success:(void (^)(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                             failure:(void (^)(ASDKAcquringSdkError *error))failure
{
    ASDKAcquringSdkError *buildError;
    
    ASDKFinishAuthorizeRequestBuilder *builder = [ASDKFinishAuthorizeRequestBuilder builderWithPaymentId:paymentId
																								cardData:cardData
																							   infoEmail:infoEmail
																							 terminalKey:self.terminalKey
																								password:self.password
																					encryptedPaymentData:encryptedPaymentData];
    
    ASDKFinishAuthorizeRequest *request = (ASDKFinishAuthorizeRequest *)[builder buildError:&buildError];
    
    if (buildError)
    {
        failure(buildError);
    }
    else
    {
        [self.acquiringApi finishAuthorizeWithRequest:request
                                             success:^(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status)
        {
            success(data, paymentInfo, status);
        }
                                             failure:^(ASDKAcquringApiError *error)
        {
            failure(error);
        }];
    }
}

- (void)chargeWithPaymentId:(NSString *)paymentId
                   rebillId:(NSNumber *)rebillId
                    success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                    failure:(void (^)(ASDKAcquringSdkError *error))failure
{
    ASDKAcquringSdkError *buildError;
    
    ASDKChargeRequestBuilder *builder = [ASDKChargeRequestBuilder builderWithPaymentId:paymentId
																			  rebillId:rebillId
																		   terminalKey:self.terminalKey
																			  password:self.password];
    
    ASDKChargeRequest *request = (ASDKChargeRequest *)[builder buildError:&buildError];
    
    if (buildError)
    {
        failure(buildError);
    }
    else
    {
        [self.acquiringApi chargeWithRequest:request
                                    success:^(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status)
        {
            success(paymentInfo, status);
        }
                                    failure:^(ASDKAcquringApiError *error)
        {
            failure(error);
        }];
    }
}

- (void)getStateWithPaymentId:(NSString *)paymentId
                      success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                      failure:(void (^)(ASDKAcquringSdkError *error))failure
{
    ASDKAcquringSdkError *buildError;
    
    ASDKGetStateRequestBuilder *builder = [ASDKGetStateRequestBuilder builderWithPaymentId:paymentId
                                                                                    terminalKey:self.terminalKey
                                                                                       password:self.password];
    
    ASDKGetStateRequest *request = (ASDKGetStateRequest *)[builder buildError:&buildError];
    
    if (buildError)
    {
        failure(buildError);
    }
    else
    {
        [self.acquiringApi getStateWithRequest:request
                                      success:^(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status)
        {
            success(paymentInfo, status);
        }
                                      failure:^(ASDKAcquringApiError *error)
        {
            failure(error);
        }];
    }
}

- (void)getCardListWithCustomerKey:(NSString *)customerKey
                           success:(void (^)(ASDKGetCardListResponse *response))success
                           failure:(void (^)(ASDKAcquringSdkError *error))failure
{
    ASDKAcquringSdkError *buildError;
    
    ASDKGetCardListRequestBuilder *builder = [ASDKGetCardListRequestBuilder builderWithCustomerKey:customerKey
                                                                                       terminalKey:self.terminalKey
                                                                                          password:self.password];
    
    ASDKGetCardListRequest *request = (ASDKGetCardListRequest *)[builder buildError:&buildError];
    
    if (buildError)
    {
        failure(buildError);
    }
    else
    {
        [self.acquiringApi getCardListWithRequest:request
                                         success:^(ASDKGetCardListResponse *response)
        {
            success(response);
        }
                                         failure:^(ASDKAcquringApiError *error)
        {
            failure(error);
        }];
    }
}

- (void)removeCardWithCustomerKey:(NSString *)customerKey
                           cardId:(NSNumber *)cardId
                          success:(void (^)(ASDKRemoveCardResponse *response))success
                          failure:(void (^)(ASDKAcquringSdkError *error))failure
{
    ASDKAcquringSdkError *buildError;
    
    ASDKRemoveCardRequestBuilder *builder = [ASDKRemoveCardRequestBuilder builderWithCardId:cardId
                                                                                     customerKey:customerKey
                                                                                     terminalKey:self.terminalKey
                                                                                        password:self.password];
    
    ASDKRemoveCardRequest *request = (ASDKRemoveCardRequest *)[builder buildError:&buildError];
    
    if (buildError)
    {
        failure(buildError);
    }
    else
    {
        [self.acquiringApi removeCardWithRequest:request
                                        success:^(ASDKRemoveCardResponse *response)
        {
            success(response);
        }
                                        failure:^(ASDKAcquringApiError *error)
        {
            failure(error);
        }];
    }
}

- (void)rejectTrancastionWithPaymentId:(NSString *)paymentId
							   success:(void (^)(ASDKCancelResponse *response))success
							   failure:(void (^)(ASDKAcquringSdkError *error))failure
{
	ASDKAcquringSdkError *buildError;
	
	ASDKCancelRequestBuilder *builder = [ASDKCancelRequestBuilder builderWithPaymentId:paymentId
																		   terminalKey:self.terminalKey
																			  password:self.password];
	
	ASDKCancelRequest *request = (ASDKCancelRequest *)[builder buildError:&buildError];
	
	if (buildError)
	{
		failure(buildError);
	}
	else
	{
		[self.acquiringApi cancelWithRequest:request
									 success:^(ASDKCancelResponse *data) {
			success(data);
		}
									 failure:^(ASDKAcquringApiError *error) {
			failure(error);
		}];
	}
}

- (void)initAttachCardWithCheckType:(NSString *)cardCheckType
						customerKey:(NSString *)customerKey
							success:(void (^)(ASDKResponseAddCardInit *response))success
							failure:(void (^)(ASDKAcquringSdkError *error))failure
{
	ASDKAcquringSdkError *buildError;

	ASDKRequestBuilderAddCardInit *builder = [[ASDKRequestBuilderAddCardInit alloc] initWithTerminalKey:self.terminalKey
																							   password:self.password
																							customerKey:customerKey
																							  checkType:cardCheckType];
	
	ASDKRequestAddCardInit *request = (ASDKRequestAddCardInit *)[builder buildError:&buildError];
	
	if (buildError)
	{
		failure(buildError);
	}
	else
	{
		[self.acquiringApi initAddCardWithRequest:request success:^(ASDKResponseAddCardInit *info) {
			success(info);
		} failure:^(ASDKAcquringApiError *error) {
			failure(error);
		}];
	}
}

- (void)finishAttachCardWithCardData:(NSString *)cardData aditionalInfo:(NSDictionary *)data requestKey:(NSString *)requestKey
							 success:(void (^)(ASDKThreeDsData *data, ASDKResponseAttachCard *result, ASDKPaymentStatus status))success
							 failure:(void (^)(ASDKAcquringSdkError *error))failure
{
	ASDKAcquringSdkError *buildError;
	
	ASDKRequestBuilderAttachCard *builder = [[ASDKRequestBuilderAttachCard alloc] initWithTerminalKey:self.terminalKey password:self.password
																						   requestKey:requestKey
																							 cardData:cardData additionalData:data];
	
	ASDKRequestAttachCard *request = (ASDKRequestAttachCard *)[builder buildError:&buildError];
	
	if (buildError)
	{
		failure(buildError);
	}
	else
	{
		[self.acquiringApi finishAddCardRequest:request success:^(ASDKThreeDsData *data, ASDKResponseAttachCard *result, ASDKPaymentStatus status) {
			success(data, result, status);
		} failure:^(ASDKAcquringApiError *error) {
			failure(error);
		}];
	}
}

- (void)getStateAttachCardWithRequestKey:(NSString *)requestKey
								 success:(void (^)(ASDKResponseGetAddCardState *response))success
								 failure:(void (^)(ASDKAcquringSdkError *error))failure
{
	ASDKAcquringSdkError *buildError;
	
	ASDKRequestBuilderGetAttachCardState *builder = [[ASDKRequestBuilderGetAttachCardState alloc] initWithTerminalKey:self.terminalKey password:self.password
																						   requestKey:requestKey];
	
	ASDKRequestGetAttachCardState *request = (ASDKRequestGetAttachCardState *)[builder buildError:&buildError];
	
	if (buildError)
	{
		failure(buildError);
	}
	else
	{		
		[self.acquiringApi getStateAttachCardRequest:request success:^(ASDKResponseGetAddCardState *response) {
			success(response);
		} failure:^(ASDKAcquringApiError *error) {
			failure(error);
		}];
	}
}

- (void)getStateSubmitRandomAmount:(NSNumber *)amount
						requestKey:(NSString *)requestKey
						   success:(void (^)(ASDKResponseGetAddCardState *response))success
						   failure:(void (^)(ASDKAcquringSdkError *error))failure
{
	ASDKAcquringSdkError *buildError;
	
	ASDKRequestBuilderSubmitRandomAmount *builder = [[ASDKRequestBuilderSubmitRandomAmount alloc] initWithTerminalKey:self.terminalKey
																											 password:self.password
																										   requestKey:requestKey amount:amount];
	
	ASDKRequestSubmitRandomAmount *request = (ASDKRequestSubmitRandomAmount *)[builder buildError:&buildError];
	
	if (buildError)
	{
		failure(buildError);
	}
	else
	{
		[self.acquiringApi getStateSubmitRandomAmount:request success:^(ASDKResponseGetAddCardState *response) {
			success(response);
		} failure:^(ASDKAcquringApiError *error) {
			failure(error);
		}];
	}
}

+ (void)getUrlWithSuccess:(void (^)(NSURL *url))success
                  failure:(void (^)(ASDKAcquringSdkError *error))failure
{

}

#pragma mark - ASDKAcquiringApiLoggerDelegate

- (void)print:(NSString *)logString
{
    if ([self debug])
    {
        [self logString:logString];
    }
}

- (void)logString:(NSString *)logString
{
    if ([self logger] && [[self logger] respondsToSelector:@selector(print:)])
    {
        [[self logger] print:logString];
    }
    else
    {
        NSLog(@"%@",logString);
    }
}

@end
