//
//  ASDKInitRequestBuilder.m
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

#import "ASDKInitRequestBuilder.h"
#import "ASDKUtilsAmount.h"

@interface ASDKInitRequestBuilder ()

@property (nonatomic, copy) NSString *amount;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *customerKey;
@property (nonatomic, copy) NSString *requestDescription;
@property (nonatomic, copy) NSString *payForm;
@property (nonatomic, copy) NSString *payType;
@property (nonatomic) BOOL recurrent;
@property (nonatomic, strong) NSDictionary *additionalPaymentData;
@property (nonatomic, strong) NSDictionary *receiptData;
@property (nonatomic, strong) NSArray *shopsData;
@property (nonatomic, strong) NSArray *shopsReceiptsData;
@property (nonatomic, copy) NSString *location;

@end

@implementation ASDKInitRequestBuilder

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
									 location:(NSString *)location
{
    ASDKInitRequestBuilder *builder = [[ASDKInitRequestBuilder alloc] init];
    
    if (builder)
    {
        builder.amount = [ASDKUtilsAmount amountWholeDigits:amount.doubleValue];
        builder.orderId = orderId;
        builder.requestDescription = description;
		builder.payType = payType;
        builder.payForm = payForm;
        builder.customerKey = customerKey;
        builder.recurrent = recurrent;
        builder.terminalKey = terminalKey;
        builder.password = password;
		builder.additionalPaymentData = data;
		builder.receiptData = receiptData;
		builder.shopsData = shopsData;
		builder.shopsReceiptsData = shopsReceiptsData;
		builder.location = location;
    }

    return builder;
}

- (ASDKAcquiringRequest *)buildError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
    [self validateError:&validationError];
    
    if (validationError)
    {
        *error = validationError;
        
        return nil;
    }
    
    NSString *token = [self makeToken];
    
	ASDKInitRequest *request = [[ASDKInitRequest alloc] initWithTerminalKey:self.terminalKey
                                                                     amount:self.amount
                                                                    orderId:self.orderId
                                                                description:self.requestDescription
                                                                      token:token
                                                                    payForm:self.payForm
																	payType:self.payType
                                                                customerKey:self.customerKey
                                                                  recurrent:self.recurrent
													  additionalPaymentData:self.additionalPaymentData
																receiptData:self.receiptData
																  shopsData:self.shopsData
														  shopsReceiptsData:self.shopsReceiptsData
																   location:self.location];

    return request;
}

- (void)validateError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;

//ОБЯЗАТЕЛЬНЫЕ ПОЛЯ
#define kASDKAmountDescription @"Сумма в копейках."
#define kASDKAmountMaxLength 10
    NSString *amount = [NSString stringWithFormat:@"%.0f",self.amount.doubleValue];
    if (amount.length > kASDKAmountMaxLength || self.amount.doubleValue <= 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKAmount details:[NSString stringWithFormat:@"%@ %@ %d",kASDKAmountDescription, kASDKValidationErrorMaxLengthString, kASDKAmountMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
#define kASDKOrderIdDescription @"Номер заказа в системе Продавца."
#define kASDKOrderIdMaxLength 50
    NSString *orderId = self.orderId;
    if (orderId.length > kASDKOrderIdMaxLength || orderId.length == 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKOrderId details:[NSString stringWithFormat:@"%@ %@ %d",kASDKOrderIdDescription, kASDKValidationErrorMaxLengthString, kASDKOrderIdMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
//ОПЦИОНАЛЬНЫЕ ПОЛЯ
#define kASDKDescriptionDescription @"Краткое описание."
#define kASDKDescriptionMaxLength 250
    NSString *requestDescription = self.requestDescription;
    if (requestDescription.length > kASDKDescriptionMaxLength)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKDescription details:[NSString stringWithFormat:@"%@ %@ %d",kASDKDescriptionDescription, kASDKValidationErrorMaxLengthString, kASDKDescriptionMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
#define kASDKPayFormDescription @"Название шаблона формы оплаты продавца."
#define kASDKPayFormMaxLength 20
    NSString *payForm = self.payForm;
    if (payForm.length > kASDKPayFormMaxLength)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKPayForm details:[NSString stringWithFormat:@"%@ %@ %d",kASDKPayFormDescription, kASDKValidationErrorMaxLengthString, kASDKPayFormMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
#define kASDKCustomerKeyDescription @"Идентификатор покупателя в системе Продавца. Если передается и Банком разрешена автоматическая привязка карт к терминалу, то для данного покупателя будет осуществлена привязка карты."
#define kASDKCustomerKeyMaxLength 36
    NSString *customerKey = self.customerKey;
    if (customerKey.length > kASDKCustomerKeyMaxLength)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKCustomerKey details:[NSString stringWithFormat:@"%@ %@ %d",kASDKCustomerKeyDescription, kASDKValidationErrorMaxLengthString, kASDKCustomerKeyMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
	
	if ([self.additionalPaymentData count] > 0)
	{
		BOOL invalidAdditionalPaymentData = NO;
		if ([[self.additionalPaymentData allKeys] count] > 20)
		{
			invalidAdditionalPaymentData = YES;
		}
		else for (NSString *key in [self.additionalPaymentData allKeys])
		{
			NSString *value = [NSString stringWithFormat:@"%@", [self.additionalPaymentData objectForKey:key]];
			if ([key length] > 20 || [value length] > 100)
			{
				invalidAdditionalPaymentData = YES;
				break;
			}
		}

		if (invalidAdditionalPaymentData == YES)
		{
			validationError = [ASDKAcquringSdkError errorWithMessage:kASDKDATA details:@"Ключ – 20 знаков, Значение – 100 знаков. Максимальное количество пар «ключ-значение» не может превышать 20." code:0];
			[(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
			*error = validationError;
		}
	}
}

- (NSDictionary *)parametersForToken
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey : [self terminalKey],
                                                                                      kASDKPassword : [self password]}];
    if (self.amount)
    {
        [parameters setObject:self.amount forKey:kASDKAmount];
    }

    if (self.orderId.length > 0)
    {
        [parameters setObject:self.orderId forKey:kASDKOrderId];
    }

    if (self.requestDescription.length > 0)
    {
        [parameters setObject:self.requestDescription forKey:kASDKDescription];
    }

    if (self.payForm.length > 0)
    {
        [parameters setObject:self.payForm forKey:kASDKPayForm];
    }

	if (self.payType.length > 0)
	{
		[parameters setObject:self.payType forKey:kASDKPayType];
	}

    if (self.customerKey.length > 0)
    {
        [parameters setObject:self.customerKey forKey:kASDKCustomerKey];
    }
    
    if (self.recurrent)
    {
        [parameters setObject:@"Y" forKey:kASDKRecurrent];
    }

	if (self.location && [self.location rangeOfString:@"ru_"].location == NSNotFound)
	{
		[parameters setObject:@"en" forKey:@"Language"];
	}

    return parameters;
}

- (NSString *)encodeURL:(NSString *)string
{
	NSMutableCharacterSet * characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"];
	[characterSet invert];
	NSString *newString = [string stringByAddingPercentEncodingWithAllowedCharacters:characterSet];

	if (newString)
	{
		return newString;
	}

	return @"";
}

@end
