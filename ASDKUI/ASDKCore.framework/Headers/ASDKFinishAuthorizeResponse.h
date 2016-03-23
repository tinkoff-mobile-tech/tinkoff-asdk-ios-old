//
//  ASDKFinishAuthorizeResponse.h
//  ASDKCore
//
//  Created by spb-EOrlova on 02.02.16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import "ASDKAcquiringResponse.h"

@interface ASDKFinishAuthorizeResponse : ASDKAcquiringResponse

@property (nonatomic, strong) NSNumber *paymentId;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSURL *ACSUrl;
@property (nonatomic, copy) NSString *MD;
@property (nonatomic, copy) NSString *paReq;

@end
