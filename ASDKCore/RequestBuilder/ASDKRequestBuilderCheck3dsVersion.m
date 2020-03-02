//
//  ASDKRequestBuilderCheck3dsVersion.m
//  ASDKCore
//
//  Created by v.budnikov on 17.02.2020.
//  Copyright © 2020 TCS Bank. All rights reserved.
//

#import "ASDKRequestBuilderCheck3dsVersion.h"

@interface ASDKRequestBuilderCheck3dsVersion ()

@property (nonatomic, copy) NSString *cardData;
@property (nonatomic, copy) NSString *paymentId;

@end


@implementation ASDKRequestBuilderCheck3dsVersion

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
						   password:(NSString *)password
						  paymentId:(NSString *)paymentId
						   cardData:(NSString *)cardData
{
	if (self = [super initWithTerminalKey:terminalKey password:password])
	{
		_cardData = cardData;
		_paymentId = paymentId;
	}
	
	return self;
}

- (ASDKRequestCheck3dsVersion *)buildError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError = nil;
	
	[self validateError:&validationError];
	
	if (validationError)
	{
		*error = validationError;
		
		return nil;
	}
	
	NSString *token = [self makeToken];
	
	ASDKRequestCheck3dsVersion *request = [[ASDKRequestCheck3dsVersion alloc] initWithTerminalKey:self.terminalKey
																						paymentId:self.paymentId
																						 cardData:self.cardData
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
	
#define kASDKCardDataDescription @"Зашифрованные данные карты."
	NSString *cardData = self.cardData;
	if (cardData.length == 0)
	{
		validationError = [ASDKAcquringSdkError errorWithMessage:kASDKCardData details:[NSString stringWithFormat:@"%@", kASDKCardDataDescription] code:0];
		
		[(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
		
		*error = validationError;
		
		return;
	}
}

- (NSDictionary *)parametersForToken
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey: [self terminalKey],
																					  kASDKPassword: [self password]}];
	
	if (self.paymentId)
	{
		[parameters setObject:self.paymentId forKey:kASDKPaymentId];
	}
	
	if (self.cardData.length > 0)
	{
		[parameters setObject:self.cardData forKey:kASDKCardData];
	}
	
	return parameters;
}

@end
