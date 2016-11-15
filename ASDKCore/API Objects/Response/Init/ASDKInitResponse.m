//
//  ASDKInitResponse.m
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



#import "ASDKInitResponse.h"

@implementation ASDKInitResponse

- (void)clearAllProperties
{
    _paymentId = nil;
    _amount = nil;
    _orderId = nil;
}

- (NSString *)paymentId
{
    if (!_paymentId)
    {
        _paymentId =[_dictionary objectForKey:kASDKPaymentId];

        //if (![_paymentId isKindOfClass:[NSNumber class]])
        //{
        //    _paymentId = [NSNumber numberWithDouble:_paymentId.doubleValue];
        //}
    }
    
    return _paymentId;
}

- (NSNumber *)amount
{
    if (!_amount)
    {
        _amount =_dictionary[kASDKAmount];
    }
    
    return _amount;
}

- (NSString *)orderId
{
    if (!_orderId)
    {
        _orderId =_dictionary[kASDKOrderId];
    }
    
    return _orderId;
}

@end
