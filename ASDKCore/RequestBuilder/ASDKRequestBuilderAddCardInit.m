//
//  ASDKRequestBuilderAddCardInit.m
//  ASDKCore
//
//  Created by v.budnikov on 12.10.17.
//  Copyright © 2017 Tinkoff Bank. All rights reserved.
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
//

#import "ASDKRequestBuilderAddCardInit.h"

@interface ASDKRequestBuilderAddCardInit ()

@property (nonatomic, copy) NSString *customerKey;
@property (nonatomic, copy) NSString *checkType;

@end

@implementation ASDKRequestBuilderAddCardInit

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
						   password:(NSString *)password
						customerKey:(NSString *)customerKey
						  checkType:(NSString *)checkType

{
	if (self = [super initWithTerminalKey:terminalKey password:password])
	{
		_customerKey = customerKey;
		_checkType =checkType;
	}

	return self;
}

- (ASDKRequestAddCardInit *)buildError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError = nil;
	
	//[self validateError:&validationError];
	
	if (validationError)
	{
		*error = validationError;
		
		return nil;
	}
	
	NSString *token = [self makeToken];
	
	ASDKRequestAddCardInit *request = [[ASDKRequestAddCardInit alloc] initWithTerminalKey:self.terminalKey
																					token:token
																				checkType:self.checkType
																			  customerKey:self.customerKey];
	
	return request;
}

//- (void)validateError:(ASDKAcquringSdkError **)error
//{
//	ASDKAcquringSdkError *validationError;
//
//#define kASDKPaymentIdDescription @"Уникальный идентификатор транзакции в системе Банка, полученный в ответе на вызов метода Init."
//#define kASDKPaymentIdMaxLength 20
//	NSString *paymentId = self.paymentId;
//	if (paymentId.length > kASDKPaymentIdMaxLength || paymentId.length == 0)
//	{
//		validationError = [ASDKAcquringSdkError errorWithMessage:kASDKPaymentId details:[NSString stringWithFormat:@"%@ %@ %d",kASDKPaymentIdDescription, kASDKValidationErrorMaxLengthString, kASDKPaymentIdMaxLength] code:0];
//
//		[(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
//
//		*error = validationError;
//
//		return;
//	}
//}

- (NSDictionary *)parametersForToken
{
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey: [self terminalKey], kASDKPassword: [self password]}];

	if ([self.checkType length] > 0)
	{
		[parameters setObject:self.checkType forKey:@"CheckType"];
	}

	if ([self.customerKey length] > 0)
	{
		[parameters setObject:self.customerKey forKey:@"CustomerKey"];
	}

	return parameters;
}



@end
