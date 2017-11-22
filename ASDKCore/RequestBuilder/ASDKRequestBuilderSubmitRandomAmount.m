//
//  ASDKRequestBuilderSubmitRandomAmount.m
//  ASDKCore
//
//  Created by v.budnikov on 16.10.17.
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

#import "ASDKRequestBuilderSubmitRandomAmount.h"
#import "ASDKRequestSubmitRandomAmount.h"

@interface ASDKRequestBuilderSubmitRandomAmount ()

@property (nonatomic, copy) NSString *requestKey;
@property (nonatomic, copy) NSNumber *amount;

@end

@implementation ASDKRequestBuilderSubmitRandomAmount

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
						   password:(NSString *)password
						 requestKey:(NSString *)requestKey
							 amount:(NSNumber *)amount
{
	if (self = [super initWithTerminalKey:terminalKey password:password])
	{
		_requestKey = requestKey;
		_amount = [NSNumber numberWithInteger:[NSString stringWithFormat:@"%.0f", amount.doubleValue].integerValue];
	}
	
	return self;
}

- (ASDKRequestSubmitRandomAmount *)buildError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError = nil;
	
	//[self validateError:&validationError];
	
	if (validationError)
	{
		*error = validationError;
		
		return nil;
	}
	
	NSString *token = [self makeToken];
	
	ASDKRequestSubmitRandomAmount *request = [[ASDKRequestSubmitRandomAmount alloc] initWithTerminalKey:[self terminalKey] token:token requestKey:[self requestKey] amount:self.amount];
	
	return request;
}

//- (void)validateError:(ASDKAcquringSdkError **)error
//{
//	ASDKAcquringSdkError *validationError;
//
//#define kASDKCardDataDescription @"Зашифрованные данные карты."
//	NSString *cardData = self.cardData;
//	if (cardData.length == 0)
//	{
//		validationError = [ASDKAcquringSdkError errorWithMessage:kASDKCardData details:[NSString stringWithFormat:@"%@", kASDKCardDataDescription] code:0];
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
	
	if (self.requestKey.length > 0)
	{
		[parameters setObject:self.requestKey forKey:@"RequestKey"];
	}
	
	if (self.amount)
	{
		[parameters setObject:self.amount.stringValue forKey:kASDKAmount];
	}
	
	return parameters;
}

@end
