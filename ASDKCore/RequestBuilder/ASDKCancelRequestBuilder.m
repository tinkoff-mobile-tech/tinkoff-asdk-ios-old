//
//  ASDKCancelRequestBuilder.m
//  ASDKCore
//
//  Created by v.budnikov on 08.02.17.
//  Copyright © 2017 TCS Bank. All rights reserved.
//

#import "ASDKCancelRequestBuilder.h"

@interface ASDKCancelRequestBuilder ()

@property (nonatomic, strong) NSString *paymentId;

@end

@implementation ASDKCancelRequestBuilder

+ (ASDKCancelRequestBuilder *)builderWithPaymentId:(NSString *)paymentId
									   terminalKey:(NSString *)terminalKey
										  password:(NSString *)password
{
	ASDKCancelRequestBuilder *builder = [[ASDKCancelRequestBuilder alloc] init];
	
	if (builder)
	{
		builder.paymentId = paymentId;
		builder.terminalKey = terminalKey;
		builder.password = password;
	}
	
	return builder;
}

- (ASDKCancelRequest *)buildError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError;
	
	[self validateError:&validationError];
	
	if (validationError)
	{
		*error = validationError;
		
		return nil;
	}
	
	NSString *token = [self makeToken];
	
	ASDKCancelRequest *request = [[ASDKCancelRequest alloc] initWithTerminalKey:self.terminalKey
																	  paymentId:self.paymentId
																		  token:token];
	
	return request;
}

- (void)validateError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError;
	
#define kASDKPaymentIdDescription @"Уникальный идентификатор транзакции в системе Банка, полученный в ответе на вызов метода Init."
#define kASDKPaymentIdMaxLength 20
	NSString *paymentId = self.paymentId;
	if (paymentId.length > kASDKPaymentIdMaxLength || paymentId.length == 0)
	{
		validationError = [ASDKAcquringSdkError errorWithMessage:kASDKPaymentId details:[NSString stringWithFormat:@"%@ %@ %d",kASDKPaymentIdDescription, kASDKValidationErrorMaxLengthString, kASDKPaymentIdMaxLength] code:0];
		
		[(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
		
		*error = validationError;
		
		return;
	}
}

- (NSDictionary *)parametersForToken
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey : [self terminalKey],
																					  kASDKPassword : [self password]}];
	
	if (self.paymentId)
	{
		[parameters setObject:self.paymentId forKey:kASDKPaymentId];
	}
	
	return parameters;
}

@end
