//
//  ASDKRemoveCardResponse.h
//  ASDKCore
//
//  Created by spb-EOrlova on 02.02.16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import "ASDKAcquiringResponse.h"

@interface ASDKRemoveCardResponse : ASDKAcquiringResponse

@property (nonatomic, strong) NSNumber *cardId;
@property (nonatomic, copy) NSString *customerKey;

@end
