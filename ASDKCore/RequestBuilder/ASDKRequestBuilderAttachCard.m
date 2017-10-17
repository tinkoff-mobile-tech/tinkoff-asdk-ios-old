//
//  ASDKRequestBuilderAttachCard.m
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

#import "ASDKRequestBuilderAttachCard.h"

@interface ASDKRequestBuilderAttachCard ()

@property (nonatomic, copy) NSString *cardData;
@property (nonatomic, copy) NSString *requestKey;
@property (nonatomic, copy) NSDictionary *additionalData;

@end

@implementation ASDKRequestBuilderAttachCard

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
						   password:(NSString *)password
						 requestKey:(NSString *)requestKey
						   cardData:(NSString *)cardData
					 additionalData:(NSDictionary *)data
{
	if (self = [super initWithTerminalKey:terminalKey password:password])
	{
		_requestKey = requestKey;
		_cardData = cardData;
		_additionalData = data;
	}
	
	return self;
}

- (ASDKRequestAttachCard *)buildError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError = nil;
	
	[self validateError:&validationError];
	
	if (validationError)
	{
		*error = validationError;
		
		return nil;
	}
	
	NSString *token = [self makeToken];
	
	ASDKRequestAttachCard *request = [[ASDKRequestAttachCard alloc] initWithTerminalKey:self.terminalKey
																				  token:token
																			   cardData:self.cardData
																			 requestKey:self.requestKey
																		 additionalData:self.additionalData];
	
	return request;
}

- (void)validateError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError;

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
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey: [self terminalKey], kASDKPassword: [self password]}];
	
	if (self.cardData.length > 0)
	{
		[parameters setObject:self.cardData forKey:@"CardData"];
	}
	
	if (self.requestKey.length > 0)
	{
		[parameters setObject:self.requestKey forKey:@"RequestKey"];
	}
	
	return parameters;
}

@end
