//
//  ASDKCardData.m
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

#import "ASDKCardData.h"
#import "ASDKCryptoUtils.h"
#import "ASDKApiKeys.h"
#import "RSA.h"

@implementation ASDKCardData

@synthesize cardData = _cardData;

- (instancetype)initWithPan:(NSString *)pan
                 expiryDate:(NSString *)expiryDate
               securityCode:(NSString *)securityCode
                     cardId:(NSString *)cardId
               publicKeyRef:(SecKeyRef)pubKeyRef
{
    self = [super init];
    if (self)
    {
        [self buildCardDataWithPan:pan expiryDate:expiryDate securityCode:securityCode cardId:cardId publicKeyRef:pubKeyRef];
    }
    
    return self;
}

- (void)buildCardDataWithPan:(NSString *)pan expiryDate:(NSString *)expiryDate securityCode:(NSString *)securityCode cardId:(NSString *)cardId publicKeyRef:(SecKeyRef)pubKeyRef
{
    NSString *cvv = [kASDKCVV stringByAppendingString:[NSString stringWithFormat:@"=%@", securityCode]];
    
    NSString *cardData;
    
    if (cardId.length > 0)
    {
        NSString *cardIdString = [kASDKCardId stringByAppendingString:[NSString stringWithFormat:@"=%@", cardId]];
        
        cardData = [NSString stringWithFormat:@"%@;%@", cardIdString, cvv];
    }
    else
    {
        NSString *panString = [kASDKPAN stringByAppendingString:[NSString stringWithFormat:@"=%@", pan]];
        NSString *expiryDateString = [kASDKExpDate stringByAppendingString:[NSString stringWithFormat:@"=%@", expiryDate]];
        
        cardData = [NSString stringWithFormat:@"%@;%@;%@", panString, expiryDateString, cvv];
    }
    
    NSLog(@"CARD DATA: %@",cardData);
    
    if (!pubKeyRef)
    {
        NSLog(@"\n\n\n\nNO KEY REF!!!\n\n\n\n\n\n");
    }
    
    _cardData = [RSA encryptString:cardData publicKeyRef:pubKeyRef];
    
    NSLog(@"ENCRYPTED CARD DATA: %@",_cardData);
}

@end
