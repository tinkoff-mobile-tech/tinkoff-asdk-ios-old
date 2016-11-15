//
//  ASDKFinishAuthorizeRequestBuilder.m
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

#import "ASDKFinishAuthorizeRequestBuilder.h"

@interface ASDKFinishAuthorizeRequestBuilder ()

@property (nonatomic, strong) NSString *paymentId;
@property (nonatomic) NSString *sendEmail;
@property (nonatomic, copy) NSString *cardData;
@property (nonatomic, strong) NSString *infoEmail;
@property (nonatomic, copy) NSString *encryptedPaymentData;

@end

@implementation ASDKFinishAuthorizeRequestBuilder

+ (ASDKFinishAuthorizeRequestBuilder *)builderWithPaymentId:(NSString *)paymentId
												   cardData:(NSString *)cardData
												  infoEmail:(NSString *)infoEmail
												terminalKey:(NSString *)terminalKey
												   password:(NSString *)password
									   encryptedPaymentData:(NSString *)encryptedPaymentData
{
    ASDKFinishAuthorizeRequestBuilder *builder = [[ASDKFinishAuthorizeRequestBuilder alloc] init];
    
    if (builder)
    {
        builder.paymentId = paymentId;
        builder.sendEmail = [builder sendEmailStringFromBool:(infoEmail.length > 0)];
        builder.cardData = cardData;
        builder.infoEmail = infoEmail;
        builder.terminalKey = terminalKey;
        builder.password = password;
		builder.encryptedPaymentData = encryptedPaymentData;
    }
    
    return builder;
}

- (NSString *)sendEmailStringFromBool:(BOOL)sendEmailBool
{
    return sendEmailBool ? @"true" : @"false";
}

- (ASDKFinishAuthorizeRequest *)buildError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
    [self validateError:&validationError];
    
    if (validationError)
    {
        *error = validationError;
        
        return nil;
    }
    
    NSString *token = [self makeToken];
    
    ASDKFinishAuthorizeRequest *request = [[ASDKFinishAuthorizeRequest alloc] initWithTerminalKey:self.terminalKey
                                                                                        paymentId:self.paymentId
                                                                                        sendEmail:self.sendEmail
                                                                                         cardData:self.cardData
                                                                                        infoEmail:self.infoEmail
                                                                                            token:token
																			 encryptedPaymentData:self.encryptedPaymentData];
    
    return request;
}

- (void)validateError:(ASDKAcquringSdkError **)error
{
    ASDKAcquringSdkError *validationError;
    
#define kASDKPaymentIdDescription @"Уникальный идентификатор транзакции в системе Банка, полученный в ответе на вызов метода Init."
#define kASDKPaymentIdMaxLength 20
    NSString *paymentId = self.paymentId;
    NSLog(@"paymentId=%@\nrealPaymentId=%@",paymentId,self.paymentId);
    if (paymentId.length > kASDKPaymentIdMaxLength || paymentId.length == 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKPaymentId details:[NSString stringWithFormat:@"%@ %@ %d",kASDKPaymentIdDescription, kASDKValidationErrorMaxLengthString, kASDKPaymentIdMaxLength] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
    
#define kASDKCardDataDescription @"Зашифрованные данные карты."
    NSString *cardData = self.cardData;
    if (cardData.length == 0 && [self.encryptedPaymentData length] == 0)
    {
        validationError = [ASDKAcquringSdkError errorWithMessage:kASDKCardData details:[NSString stringWithFormat:@"%@",kASDKCardDataDescription] code:0];
        
        [(ASDKAcquringSdkError *)validationError setIsSdkError:NO];
        
        *error = validationError;
        
        return;
    }
}

- (NSDictionary *)parametersForToken
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{kASDKTerminalKey : self.terminalKey,
                                                                                      kASDKPassword : self.password,
                                                                                      kASDKSendEmail : self.sendEmail}];
    
    if (self.paymentId)
    {
        [parameters setObject:self.paymentId forKey:kASDKPaymentId];
    }

    if (self.cardData.length > 0)
    {
        [parameters setObject:self.cardData forKey:kASDKCardData];
    }
    if (self.infoEmail.length > 0)
    {
        [parameters setObject:self.infoEmail forKey:kASDKInfoEmail];
    }
	if (self.encryptedPaymentData.length > 0)
	{
		[parameters setObject:self.encryptedPaymentData forKey:@"EncryptedPaymentData"];
	}

    return parameters;
}


@end
