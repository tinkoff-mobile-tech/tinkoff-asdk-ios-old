//
//  ASDKAcquringSdkError.m
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

#import "ASDKAcquringSdkError.h"
#import "ASDKApiKeys.h"

@implementation ASDKAcquringSdkError

+ (instancetype)errorWithMessage:(NSString *)message details:(NSString *)details code:(NSInteger)code
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if (message)
    {
        [userInfo setObject:message forKey:kASDKErrorMessage];
    }
    
    if (details)
    {
        [userInfo setObject:details forKey:kASDKErrorDetails];
    }
    
    ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithDomain:kTCSErrorDomain
                                                                   code:code
                                                               userInfo:userInfo];
    
    error.isSdkError = YES;
    
    return error;
}

+ (instancetype)acquiringErrorWithError:(NSError *)error
{
    ASDKAcquringSdkError *sdkError = [ASDKAcquringSdkError errorWithMessage:error.localizedDescription details:nil code:error.code];
    
    sdkError.isSdkError = NO;
    
    return sdkError;
}

- (NSString *)errorMessage
{
    return self.userInfo[kASDKErrorMessage];
}

- (NSString *)errorDetails
{	
	if (self.userInfo[kASDKErrorDetails])
	{
		return self.userInfo[kASDKErrorDetails];
	}
	
	if (self.userInfo[kASDKErrorCode])
	{
		return [NSString stringWithFormat:@"%@", self.userInfo[kASDKErrorCode]];
	}

	return nil;
}


@end
