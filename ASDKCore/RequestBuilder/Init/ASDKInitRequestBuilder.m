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

@interface ASDKInitRequestBuilder ()

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *customerKey;
@property (nonatomic, copy) NSString *requestDescription;
@property (nonatomic, copy) NSString *payForm;
@property (nonatomic) BOOL recurrent;

@end

@implementation ASDKInitRequestBuilder

+ (ASDKInitRequestBuilder *)builderWithAmount:(NSNumber *)amount
                                      orderId:(NSString *)orderId
                                  description:(NSString *)description
                                      payForm:(NSString *)payForm
                                  customerKey:(NSString *)customerKey
                                    recurrent:(BOOL)recurrent
                                  terminalKey:(NSString *)terminalKey
                                     password:(NSString *)password
{
    ASDKInitRequestBuilder *builder = [[ASDKInitRequestBuilder alloc] init];
    
    if (builder)
    {
        builder.amount = [NSNumber numberWithDouble:[NSString stringWithFormat:@"%.2f",amount.doubleValue].doubleValue];
        builder.orderId = orderId;
        builder.requestDescription = description;
        builder.payForm = payForm;
        builder.customerKey = customerKey;
        builder.recurrent = recurrent;
        builder.terminalKey = terminalKey;
        builder.password = password;
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
                                                                customerKey:self.customerKey
                                                                  recurrent:self.recurrent];
    
    return request;
}

- (void)validateError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;

//ОБЯЗАТЕЛЬНЫЕ ПОЛЯ
#define kASDKAmountDescription @"Сумма в копейках."
#define kASDKAmountMaxLength 10
    NSString *amount = [NSString stringWithFormat:@"%.2f",self.amount.doubleValue];
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
}

- (NSDictionary *)parametersForToken
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey : [self terminalKey],
                                                                                      kASDKPassword : [self password]}];
    if (self.amount)
    {
        [parameters setObject:self.amount.stringValue forKey:kASDKAmount];
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
    
    if (self.customerKey.length > 0)
    {
        [parameters setObject:self.customerKey forKey:kASDKCustomerKey];
    }
    
    if (self.recurrent)
    {
        [parameters setObject:@"Y" forKey:kASDKRecurrent];
    }
    
    return parameters;
}

@end
