//
//  ASDKAcquringApiError.m
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

#import "ASDKAcquringApiError.h"

@implementation ASDKAcquringApiError

+ (instancetype)errorWithAcquringResponse:(ASDKAcquiringResponse *)response urlString:(NSString *)urlString parameters:(NSDictionary *)parameters code:(NSInteger)code
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if (response)
    {
        [userInfo setObject:response forKey:kASDKAcquringResponse];
        
        if (response.message)
        {
            [userInfo setObject:response.message forKey:kASDKErrorMessage];
        }
        
        if (response.details)
        {
            [userInfo setObject:response.details forKey:kASDKErrorDetails];
        }
    }
    
    ASDKAcquringApiError *error = [ASDKAcquringApiError errorWithDomain:kTCSErrorDomain
                                                                   code:code
                                                               userInfo:userInfo];
    
    error.urlString = urlString;
    error.parameters = parameters;
    error.apiResponse = response;
    
    error.isSdkError = YES;
    
    return error;
}

- (NSString *)errorMessage
{
    return self.apiResponse.message ? : self.userInfo[kASDKErrorMessage];
}

- (NSString *)errorDetails
{
    return self.apiResponse.details ? : self.userInfo[kASDKErrorDetails];
}

@end
