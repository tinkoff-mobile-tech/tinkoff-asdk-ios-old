//
//  ASDKInitResponse.h
//  ASDKCore
//
//  Created by spb-EOrlova on 02.02.16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import "ASDKAcquiringResponse.h"

@interface ASDKInitResponse : ASDKAcquiringResponse

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) NSNumber *paymentId;

@end
