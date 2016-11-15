//
//  ASDKGetStateRequestBuilder.m
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

#import "ASDKGetStateRequestBuilder.h"

@interface ASDKGetStateRequestBuilder ()

@property (nonatomic, strong) NSString *paymentId;

@end

@implementation ASDKGetStateRequestBuilder

+ (ASDKGetStateRequestBuilder *)builderWithPaymentId:(NSString *)paymentId
                                      terminalKey:(NSString *)terminalKey
                                         password:(NSString *)password
{
    ASDKGetStateRequestBuilder *builder = [[ASDKGetStateRequestBuilder alloc] init];
    
    if (builder)
    {
        builder.paymentId = paymentId;
        builder.terminalKey = terminalKey;
        builder.password = password;
    }
    
    return builder;
}

- (ASDKGetStateRequest *)buildError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
    [self validateError:&validationError];
    
    if (validationError)
    {
        *error = validationError;
        
        return nil;
    }
    
    NSString *token = [self makeToken];
    
    ASDKGetStateRequest *request = [[ASDKGetStateRequest alloc] initWithTerminalKey:self.terminalKey
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
