//
//  ASDKAcquiringResponse.h
//  ASDKCore
//
//  Created by spb-EOrlova on 02.02.16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASDKBaseObject.h"

typedef enum
{
    ASDKPaymentStatus_NEW,
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
    ASDKPaymentStatus_UNKNOWN
} ASDKPaymentStatus;

@interface ASDKAcquiringResponse : ASDKBaseObject

@property (nonatomic, copy) NSString *terminalKey;
@property (nonatomic) BOOL success;
@property (nonatomic) ASDKPaymentStatus status;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *details;

@end
