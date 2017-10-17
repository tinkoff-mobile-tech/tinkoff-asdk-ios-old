//
//  ASDKAcquiringResponse.h
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
#import "ASDKApiKeys.h"

typedef enum
{
    ASDKPaymentStatus_NEW = 0,
    ASDKPaymentStatus_CANCELLED,
    ASDKPaymentStatus_PREAUTHORIZING,
    ASDKPaymentStatus_FORMSHOWED,
    ASDKPaymentStatus_AUTHORIZING,
    ASDKPaymentStatus_3DS_CHECKING,
    ASDKPaymentStatus_3DS_CHECKED,
    ASDKPaymentStatus_AUTHORIZED,
    ASDKPaymentStatus_REVERSING,
    ASDKPaymentStatus_REVERSED,
    ASDKPaymentStatus_CONFIRMING,
    ASDKPaymentStatus_CONFIRMED,
    ASDKPaymentStatus_REFUNDING,
    ASDKPaymentStatus_REFUNDED,
    ASDKPaymentStatus_REJECTED,
    ASDKPaymentStatus_UNKNOWN,
	ASDKPaymentStatus_COMPLETED,
	ASDKPaymentStatus_HOLD,
	ASDKPaymentStatus_NO,
	ASDKPaymentStatus_3DSHOLD,
	ASDKPaymentStatus_LOOP,
} ASDKPaymentStatus;

@interface ASDKAcquiringResponse : ASDKBaseObject

@property (nonatomic, copy) NSString *terminalKey;
@property (nonatomic) BOOL success;
@property (nonatomic) ASDKPaymentStatus status;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *details;

+ (NSString *)localizedStatus:(ASDKPaymentStatus)status;

@end
