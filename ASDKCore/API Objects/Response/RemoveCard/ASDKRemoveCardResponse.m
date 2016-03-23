//
//  ASDKRemoveCardResponse.m
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



#import "ASDKRemoveCardResponse.h"
#import "ASDKApiKeys.h"

@implementation ASDKRemoveCardResponse

- (NSNumber *)cardId
{
    if (!_cardId)
    {
        _cardId = _dictionary[kASDKCardId];
    }
    
    return _cardId;
}

- (NSString *)customerKey
{
    if (!_customerKey)
    {
        _customerKey = _dictionary[kASDKCustomerKey];
    }
    
    return _customerKey;
}

- (void)clearAllProperties
{
    _cardId = nil;
    _customerKey = nil;
}

@end
