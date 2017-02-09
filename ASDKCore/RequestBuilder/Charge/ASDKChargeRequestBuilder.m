//
//  ASDKChargeRequestBuilder.m
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

#import "ASDKChargeRequestBuilder.h"

@interface ASDKChargeRequestBuilder ()

@property (nonatomic, strong) NSString *paymentId;
@property (nonatomic, strong) NSNumber *rebillId;

@end

@implementation ASDKChargeRequestBuilder

+ (ASDKChargeRequestBuilder *)builderWithPaymentId:(NSString *)paymentId
                                       rebillId:(NSNumber *)rebillId
                                    terminalKey:(NSString *)terminalKey
                                       password:(NSString *)password
{
    ASDKChargeRequestBuilder *builder = [[ASDKChargeRequestBuilder alloc] init];
    
    if (builder)
    {
        builder.paymentId = paymentId;
        builder.rebillId = rebillId;
        builder.terminalKey = terminalKey;
        builder.password = password;
    }
    
    return builder;
}

- (ASDKChargeRequest *)buildError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
    [self validateError:&validationError];
    
    if (validationError)
    {
        *error = validationError;
        
        return nil;
    }
    
    NSString *token = [self makeToken];
    
    ASDKChargeRequest *request = [[ASDKChargeRequest alloc] initWithTerminalKey:self.terminalKey
                                                                      paymentId:self.paymentId
                                                                       rebillId:self.rebillId
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
    
#define kASDKRebillIdDescription @"Идентификатор рекуррентного платежа."
#define kASDKRebillIdMaxLength 20
    NSString *rebillId = self.rebillId.stringValue;
    if (rebillId.length > kASDKRebillIdMaxLength || rebillId.length == 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKRebillId details:[NSString stringWithFormat:@"%@ %@ %d",kASDKRebillIdDescription, kASDKValidationErrorMaxLengthString, kASDKRebillIdMaxLength] code:0];
        
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
    if (self.rebillId)
    {
        [parameters setObject:self.rebillId forKey:kASDKRebillId];
    }
    
    return parameters;
}


@end
