//
//  ASDKRequestBuilderGetAttachCardState.m
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

#import "ASDKRequestBuilderGetAttachCardState.h"

@interface ASDKRequestBuilderGetAttachCardState ()

@property (nonatomic, copy) NSString *requestKey;

@end

@implementation ASDKRequestBuilderGetAttachCardState

- (instancetype)initWithTerminalKey:(NSString *)terminalKey
						   password:(NSString *)password
						 requestKey:(NSString *)requestKey

{
	if (self = [super initWithTerminalKey:terminalKey password:password])
	{
		_requestKey = requestKey;
	}

	return self;
}

- (ASDKRequestGetAttachCardState *)buildError:(ASDKAcquringSdkError **)error
{
	ASDKAcquringSdkError *validationError = nil;
	
	//[self validateError:&validationError];
	
	if (validationError)
	{
		*error = validationError;
		
		return nil;
	}
	
	NSString *token = [self makeToken];
	
	ASDKRequestGetAttachCardState *request = [[ASDKRequestGetAttachCardState alloc] initWithTerminalKey:[self terminalKey] token:token requestKey:[self requestKey]];
	
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
	
	return parameters;
}

@end
