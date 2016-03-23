//
//  ASDKCard.h
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

#import <Foundation/Foundation.h>
#import "ASDKBaseObject.h"

typedef enum
{
    ASDKCardStatusActive,
    ASDKCardStatusInactive,
    ASDKCardStatusDeleted,
    ASDKCardStatusUnknown
} ASDKCardStatus;

typedef enum
{
    ASDKCardTypeVisa = '4',
    ASDKCardTypeMastercard = '5',
    ASDKCardTypeMaestro = '6'
} ASDKCardType;

@interface ASDKCard : ASDKBaseObject

@property (nonatomic, copy) NSString *pan;
@property (nonatomic, strong) NSString *cardId;
@property (nonatomic) ASDKCardStatus status;
@property (nonatomic, strong) NSNumber *rebillId;
@property (nonatomic) ASDKCardType cardType;

- (NSString *)panExtraShort;

@end
