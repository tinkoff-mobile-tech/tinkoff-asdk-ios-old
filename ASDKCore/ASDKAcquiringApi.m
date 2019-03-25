//
//  ASDKAcquiringApi.m
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

#import "ASDKAcquiringApi.h"
#import "ASDKApiKeys.h"
#import "ASDKAcquringApiError.h"

typedef NS_ENUM(NSInteger, APIVersion)
{
	APIVersion_v1 = 1,
	APIVersion_v2 = 2
};

@interface ASDKAcquiringApi ()

@end

@implementation ASDKAcquiringApi


- (void)dealloc
{
    NSLog(@"API DEALLOC");
}

+ (ASDKAcquiringApi *)acquiringApiWithDomainPath:(NSString *)domainPath domainPath_v2:(NSString *)domainPath_v2
{
    ASDKAcquiringApi *acquiringApi = [[ASDKAcquiringApi alloc] init];
    
    acquiringApi.domainPath = domainPath;
	acquiringApi.domainPath_v2 = domainPath_v2;
	acquiringApi.requestTimeoutInterval = 120;
	
    return acquiringApi;
}

- (void)apiVersion:(APIVersion)apiVersion path:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(NSDictionary *responseDictionary, NSURLResponse *response))success  failure:(void (^)(ASDKAcquringApiError *error))failure
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
	
	NSString *domainPath = self.domainPath;
	if (apiVersion == APIVersion_v2)
	{
		domainPath = self.domainPath_v2;
	}
	
    NSString *urlString = [NSString stringWithFormat:@"%@%@", domainPath, path];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.timeoutInterval = self.requestTimeoutInterval;
	
	if (apiVersion == APIVersion_v2)
	{
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	}
	
    [request setHTTPMethod:@"POST"];
    
	NSString *dataString = [self apiVersion:apiVersion stringFromParameters:parameters];
    NSData *postData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                      {
                                          dispatch_async(dispatch_get_main_queue(), ^
                                                         {
                                                             ASDKAcquringApiError *finalError;
                                                             NSDictionary *finalResponseDictionary;
                                                             
                                                             if (error)
                                                             {
                                                                 finalError = [ASDKAcquringApiError acquiringErrorWithError:error];
                                                             }
                                                             else
                                                             {
                                                                 NSError *jsonError;
                                                                 NSMutableDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                     options:kNilOptions
                                                                                                                                       error:&jsonError];
                                                                 
                                                                 if (jsonError)
                                                                 {
                                                                     ASDKAcquringApiError *apiJsonError = [ASDKAcquringApiError acquiringErrorWithError:jsonError];
                                                                     finalError = apiJsonError;
                                                                 }
                                                                 else
                                                                 {
                                                                     ASDKAcquiringResponse *fullResponse = [[ASDKAcquiringResponse alloc] initWithDictionary:responseJSON];
                                                                     
                                                                     BOOL isCardsListRequest = [path isEqualToString:kASDKAPIPathGetCardList];
                                                                     BOOL success;
                                                                     
                                                                     if (isCardsListRequest)
                                                                     {
                                                                         if ([responseJSON isKindOfClass:[NSDictionary class]])
                                                                         {
                                                                             success = [fullResponse success];
                                                                         }
                                                                         else
                                                                         {
                                                                             success = YES;
                                                                         }
                                                                     }
                                                                     else
                                                                     {
                                                                         success = [fullResponse success];
                                                                     }
                                                                     
                                                                     if (!success)
                                                                     {
                                                                         ASDKAcquringApiError *apiError = [ASDKAcquringApiError errorWithAcquringResponse:fullResponse
                                                                                                                                                urlString:urlString
                                                                                                                                               parameters:parameters
                                                                                                                                                     code:[responseJSON[kASDKErrorCode] integerValue]];
                                                                         if (apiError.code == kASDKApiErrorCodeEmptyCardList)
                                                                         {
                                                                             finalResponseDictionary = [NSDictionary dictionary];
                                                                         }
                                                                         else
                                                                         {
                                                                             finalError = apiError;
                                                                         }
                                                                     }
                                                                     else
                                                                     {
                                                                         finalResponseDictionary = responseJSON;
                                                                     }
                                                                 }
                                                             }
                                                
                                                             [self logRequestWithUrlString:urlString
                                                                                parameters:parameters
                                                                            responseObject:finalError ? : finalResponseDictionary];
                                                             
                                                             if (finalError)
                                                             {
                                                                 failure(finalError);
                                                             }
                                                             else
                                                             {
                                                                 success(finalResponseDictionary,response);
                                                             }
                                                         });
                                      }];
    
    [dataTask resume];
}

- (void)logRequestWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters responseObject:(id)responseObject
{
    NSString *logString = [NSString stringWithFormat:@"URL: %@\nParamaters:\n%@\nResponse:\n%@\n",urlString,parameters,responseObject];
    
    id<ASDKAcquiringApiLoggerDelegate> acquiringApiLoggerDelegate = self.acquiringApiLoggerDelegate;
    
    if (acquiringApiLoggerDelegate && [acquiringApiLoggerDelegate respondsToSelector:@selector(print:)])
    {
        [acquiringApiLoggerDelegate print:logString];
    }
    else
    {
        NSLog(@"%@",logString);
    }
}

- (NSString *)apiVersion:(APIVersion)apiVersion stringFromParameters:(NSDictionary *)parameters
{
    NSString *dataString = @"";
    
    NSCharacterSet *URLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@" \"#%/:<>?@[\\]^`{|}+="] invertedSet];
    
    for (NSString *key in parameters.allKeys)
    {
        id value = parameters[key];
        
        if ([value isKindOfClass:[NSString class]])
        {
            value = [(NSString *)value stringByAddingPercentEncodingWithAllowedCharacters:URLCombinedCharacterSet];
        }
        
        NSString *singleString = [NSString stringWithFormat:@"%@=%@",key,value];

        dataString = [NSString stringWithFormat:@"%@%@%@",dataString,dataString.length > 0 ? @"&" : @"", singleString];
    }
    
//    NSLog(@"\n\n\n\n%@\n\n\n\n",dataString);
	
	
	if (apiVersion == APIVersion_v2)
	{
		NSError *error;
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
														   options:NSJSONWritingPrettyPrinted
															 error:&error];
		if (jsonData)
		{
			dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		}
	}
	
    return dataString;
}


- (void)initWithRequest:(ASDKInitRequest *)request
                success:(void (^)(ASDKInitResponse *response))success
                failure:(void (^)(ASDKAcquringApiError *error))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey : request.terminalKey,
                                                                                      kASDKAmount      : request.amount,
                                                                                      kASDKOrderId     : request.orderId,
                                                                                      kASDKToken       : request.token}];
    if (request.requestDescription.length > 0)
    {
        [parameters setObject:request.requestDescription forKey:kASDKDescription];
    }
    
    if (request.payForm.length > 0)
    {
        [parameters setObject:request.payForm forKey:kASDKPayForm];
    }
    
    if (request.payType.length > 0)
    {
        [parameters setObject:request.payType forKey:kASDKPayType];
    }
    
    if (request.customerKey.length > 0)
    {
        [parameters setObject:request.customerKey forKey:kASDKCustomerKey];
    }
    
    if (request.recurrent)
    {
        [parameters setObject:@"Y" forKey:kASDKRecurrent];
    }
	
	if ([request.additionalPaymentData.allKeys count] > 0)
	{
		[parameters setObject:request.additionalPaymentData forKey:kASDKDATA];
	}
	
	if (request.receiptData)
	{
		[parameters setObject:request.receiptData forKey:kASDKReceipt];
	}
	
	if (request.shopsData && request.shopsData.count > 0)
	{
		[parameters setObject:request.shopsData forKey:kASDKShops];
	}
	
	if (request.shopsReceiptsData && request.shopsReceiptsData.count > 0)
	{
		[parameters setObject:request.shopsReceiptsData forKey:kASDKReceipts];
	}

	if (request.location && [request.location rangeOfString:@"ru_"].location == NSNotFound)
	{
		[parameters setObject:@"en" forKey:@"Language"];
	}

	[self apiVersion:APIVersion_v2 path:kASDKAPIPathInit parameters:parameters
       success:^(NSDictionary *responseDictionary, NSURLResponse *response)
    {
        ASDKInitResponse *responseObject = [[ASDKInitResponse alloc] initWithDictionary:responseDictionary];
        
        success(responseObject);
    }
       failure:^(ASDKAcquringApiError *error)
    {
        failure(error);
    }];
}

- (void)finishAuthorizeWithRequest:(ASDKFinishAuthorizeRequest *)request
                           success:(void (^)(ASDKThreeDsData *data, ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                           failure:(void (^)(ASDKAcquringApiError *error))failure
{
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	
	[parameters setObject:request.terminalKey forKey:kASDKTerminalKey];
	[parameters setObject:request.paymentId forKey:kASDKPaymentId];
	if ([request.cardData length] > 0) {[parameters setObject:request.cardData forKey:kASDKCardData];}
	if ([request.sendEmail length] > 0) {[parameters setObject:request.sendEmail forKey:kASDKSendEmail];}
	[parameters setObject:request.token forKey:kASDKToken];
	if ([request.encryptedPaymentData length] > 0) {[parameters setObject:request.encryptedPaymentData forKey:@"EncryptedPaymentData"];}
	
    if (request.infoEmail && [request.sendEmail boolValue])
    {
        [parameters setObject:request.infoEmail forKey:kASDKInfoEmail];
    }

    [self apiVersion:APIVersion_v2 path:kASDKAPIPathFinishAuthorize parameters:parameters
       success:^(NSDictionary *responseDictionary, NSURLResponse *response)
    {
        ASDKFinishAuthorizeResponse *responseObject = [[ASDKFinishAuthorizeResponse alloc] initWithDictionary:responseDictionary];
        
        success(responseObject.threeDsData, responseObject.paymentInfo, responseObject.status);
    }
       failure:^(ASDKAcquringApiError *error)
    {
        failure(error);
    }];
}

- (void)getStateWithRequest:(ASDKGetStateRequest *)request
                    success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                    failure:(void (^)(ASDKAcquringApiError *error))failure
{
    NSMutableDictionary *parameters = @{kASDKTerminalKey : request.terminalKey,
                                        kASDKPaymentId   : request.paymentId,
                                        kASDKToken       : request.token}.mutableCopy;
    
    [self apiVersion:APIVersion_v2 path:kASDKAPIPathGetState parameters:parameters
       success:^(NSDictionary *responseDictionary, NSURLResponse *response)
     {
         ASDKGetStateResponse *responseObject = [[ASDKGetStateResponse alloc] initWithDictionary:responseDictionary];
         
         success(responseObject.paymentInfo, responseObject.status);
     }
       failure:^(ASDKAcquringApiError *error)
     {
         failure(error);
     }];
}

- (void)chargeWithRequest:(ASDKChargeRequest *)request
                  success:(void (^)(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status))success
                  failure:(void (^)(ASDKAcquringApiError *error))failure
{
    NSMutableDictionary *parameters = @{kASDKTerminalKey : request.terminalKey,
                                        kASDKPaymentId   : request.paymentId,
                                        kASDKRebillId    : request.rebillId,
                                        kASDKToken       : request.token}.mutableCopy;
    
    [self apiVersion:APIVersion_v2 path:kASDKAPIPathCharge parameters:parameters
       success:^(NSDictionary *responseDictionary, NSURLResponse *response)
     {
         ASDKChargeResponse *responseObject = [[ASDKChargeResponse alloc] initWithDictionary:responseDictionary];
         success(responseObject.paymentInfo, responseObject.status);
     }
       failure:^(ASDKAcquringApiError *error)
     {
         failure(error);
     }];
}

- (void)getCardListWithRequest:(ASDKGetCardListRequest *)request
                       success:(void (^)(ASDKGetCardListResponse *response))success
                       failure:(void (^)(ASDKAcquringApiError *error))failure
{
    NSMutableDictionary *parameters = @{kASDKTerminalKey : request.terminalKey,
                                        kASDKCustomerKey : request.customerKey,
                                        kASDKToken       : request.token}.mutableCopy;
    
    [self apiVersion:APIVersion_v2 path:kASDKAPIPathGetCardList parameters:parameters
       success:^(NSDictionary *responseDictionary, NSURLResponse *response)
     {
         ASDKGetCardListResponse *responseObject = [[ASDKGetCardListResponse alloc] initWithDictionary:responseDictionary];
         
         success(responseObject);
     }
       failure:^(ASDKAcquringApiError *error)
     {
         failure(error);
     }];
}

- (void)removeCardWithRequest:(ASDKRemoveCardRequest *)request
                      success:(void (^)(ASDKRemoveCardResponse *response))success
                      failure:(void (^)(ASDKAcquringApiError *error))failure
{
    NSMutableDictionary *parameters = @{kASDKTerminalKey : request.terminalKey,
                                        kASDKCardId      : request.cardId,
                                        kASDKCustomerKey : request.customerKey,
                                        kASDKToken       : request.token}.mutableCopy;
    
    [self apiVersion:APIVersion_v2 path:kASDKAPIPathRemoveCard parameters:parameters
       success:^(NSDictionary *responseDictionary, NSURLResponse *response)
     {
         ASDKRemoveCardResponse *responseObject = [[ASDKRemoveCardResponse alloc] initWithDictionary:responseDictionary];
         
         success(responseObject);
     }
       failure:^(ASDKAcquringApiError *error)
     {
         failure(error);
     }];
}

- (void)cancelWithRequest:(ASDKCancelRequest *)request
				  success:(void (^)(ASDKCancelResponse *data))success
				  failure:(void (^)(ASDKAcquringApiError *error))failure
{
	NSDictionary *parameters = @{kASDKTerminalKey : request.terminalKey,
								kASDKPaymentId   : request.paymentId,
								kASDKToken       : request.token};
	
	[self apiVersion:APIVersion_v2 path:kASDKAPIPathCancel parameters:parameters
	   success:^(NSDictionary *responseDictionary, NSURLResponse *response) {
		   ASDKCancelResponse *responseObject = [[ASDKCancelResponse alloc] initWithDictionary:responseDictionary];
		   
		   success(responseObject);
	   }
	   failure:^(ASDKAcquringApiError *error) {
		   failure(error);
	   }];
}

- (void)initAddCardWithRequest:(ASDKRequestAddCardInit *)request
					   success:(void (^)(ASDKResponseAddCardInit *info))success
					   failure:(void (^)(ASDKAcquringApiError *error))failure
{
	NSDictionary *parameters = @{kASDKTerminalKey: request.terminalKey, @"CheckType": request.checkType, @"CustomerKey": request.customerKey, kASDKToken: request.token};
	
	[self apiVersion:APIVersion_v2 path:@"AddCard" parameters:parameters success:^(NSDictionary *responseDictionary, NSURLResponse *response) {
		ASDKResponseAddCardInit *responseObject = [[ASDKResponseAddCardInit alloc] initWithDictionary:responseDictionary];
		success(responseObject);
	} failure:^(ASDKAcquringApiError *error) {
		failure(error);
	}];
}

- (void)finishAddCardRequest:(ASDKRequestAttachCard *)request
					 success:(void (^)(ASDKThreeDsData *data, ASDKResponseAttachCard *result, ASDKPaymentStatus status))success
					 failure:(void (^)(ASDKAcquringApiError *error))failure
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey: request.terminalKey, @"CardData": request.cardData, @"RequestKey": request.requestKey, kASDKToken: request.token}];
	
	if ([request.additionalData.allKeys count] > 0)
	{
		[parameters setObject:request.additionalData forKey:@"DATA"];
	}

	[self apiVersion:APIVersion_v2 path:@"AttachCard" parameters:parameters success:^(NSDictionary *responseDictionary, NSURLResponse *response) {
		ASDKResponseAttachCard *responseAttachCard = [[ASDKResponseAttachCard alloc] initWithDictionary:responseDictionary];
		
		ASDKFinishAuthorizeResponse *responseObject = [[ASDKFinishAuthorizeResponse alloc] initWithDictionary:responseDictionary];
		success(responseObject.threeDsData, responseAttachCard, responseObject.status);
	
	} failure:^(ASDKAcquringApiError *error) {
		failure(error);
	}];
}

- (void)getStateAttachCardRequest:(ASDKRequestGetAttachCardState *)request
						  success:(void (^)(ASDKResponseGetAddCardState *respose))success
						  failure:(void (^)(ASDKAcquringApiError *error))failure
{
	NSDictionary *parameters = @{kASDKTerminalKey: request.terminalKey, @"RequestKey": request.requestKey, kASDKToken: request.token};
	
	[self apiVersion:APIVersion_v2 path:@"GetAddCardState" parameters:parameters
			 success:^(NSDictionary *responseDictionary, NSURLResponse *response)
	 {
		 ASDKResponseGetAddCardState *responseObject = [[ASDKResponseGetAddCardState alloc] initWithDictionary:responseDictionary];
		 success(responseObject);
	 }
			 failure:^(ASDKAcquringApiError *error)
	 {
		 failure(error);
	 }];
}

- (void)getStateSubmitRandomAmount:(ASDKRequestSubmitRandomAmount *)request
						   success:(void (^)(ASDKResponseGetAddCardState *response))success
						   failure:(void (^)(ASDKAcquringApiError *error))failure
{
	NSDictionary *parameters = @{kASDKAmount: request.amount, kASDKTerminalKey: request.terminalKey, @"RequestKey": request.requestKey, kASDKToken: request.token};
	
	[self apiVersion:APIVersion_v2 path:@"SubmitRandomAmount" parameters:parameters
			 success:^(NSDictionary *responseDictionary, NSURLResponse *response)
	 {
		 ASDKResponseGetAddCardState *responseObject = [[ASDKResponseGetAddCardState alloc] initWithDictionary:responseDictionary];
		 success(responseObject);
	 }
			 failure:^(ASDKAcquringApiError *error)
	 {
		 failure(error);
	 }];
}

@end
