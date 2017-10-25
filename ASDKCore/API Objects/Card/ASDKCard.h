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
    ASDKCardTypeMaestro = '6',
	ASDKCardTypeMIR = '2'
} ASDKCardType;

extern NSString *const ASDKCardCheckType_NO; // NO – сохранить карту без проверок. Rebill ID для рекуррентных платежей не возвращается.
extern NSString *const ASDKCardCheckType_3DS; //3DS – при сохранении карты выполнить проверку 3DS и выполнить списание, а затем отмену на 1 р. В этом случае RebillID будет только для 3DS карт. Карты, не поддерживающие 3DS, привязаны не будут.
extern NSString *const ASDKCardCheckType_HOLD; // HOLD – при сохранении сделать списание и затем отмену на 1 руб. RebillID для рекуррентных платежей возвращается в ответе.
extern NSString *const ASDKCardCheckType_3DSHOLD; //3DSHOLD – при привязке карты выполняем проверку, поддерживает карта 3DS или нет. Если карта поддерживает 3DS, далее выполняем списание и затем отмену на 1 руб.

@interface ASDKCard : ASDKBaseObject

@property (nonatomic) ASDKCardType cardType;
@property (nonatomic) ASDKCardStatus status;
@property (nonatomic, strong) NSNumber *rebillId;
@property (nonatomic, copy) NSString *pan;
@property (nonatomic, strong) NSString *cardId;

- (NSString *)panExtraShort;

@end
