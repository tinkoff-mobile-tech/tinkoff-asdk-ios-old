//
//  ASDKGetCardListRequestBuilder.m
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

#import "ASDKGetCardListRequestBuilder.h"

@interface ASDKGetCardListRequestBuilder ()

@property (nonatomic, copy) NSString *customerKey;

@end

@implementation ASDKGetCardListRequestBuilder

+ (ASDKGetCardListRequestBuilder *)builderWithCustomerKey:(NSString *)customerKey
                                           terminalKey:(NSString *)terminalKey
                                              password:(NSString *)password
{
    ASDKGetCardListRequestBuilder *builder = [[ASDKGetCardListRequestBuilder alloc] init];
    
    if (builder)
    {
        builder.customerKey = customerKey;
        builder.terminalKey = terminalKey;
        builder.password = password;
    }
    
    return builder;
}

- (ASDKGetCardListRequest *)buildError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
    [self validateError:&validationError];
    
    if (validationError)
    {
        *error = validationError;
        
        return nil;
    }
    
    NSString *token = [self makeToken];
    
    ASDKGetCardListRequest *request = [[ASDKGetCardListRequest alloc] initWithTerminalKey:self.terminalKey
                                                                              customerKey:self.customerKey
                                                                                    token:token];
    
    return request;
}

- (void)validateError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
#define kASDKCustomerKeyDescription @"Идентификатор покупателя в системе Продавца."
#define kASDKCustomerKeyMaxLength 36
    NSString *customerKey = self.customerKey;
    if (customerKey.length > kASDKCustomerKeyMaxLength || customerKey.length == 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKCustomerKey details:[NSString stringWithFormat:@"%@ %@ %d",kASDKCustomerKeyDescription, kASDKValidationErrorMaxLengthString, kASDKCustomerKeyMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
}

- (NSDictionary *)parametersForToken
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey : [self terminalKey],
                                                                                      kASDKPassword : [self password]}];
    
    if (self.customerKey.length > 0)
    {
        [parameters setObject:self.customerKey forKey:kASDKCustomerKey];
    }
    
    return parameters;
}

@end
