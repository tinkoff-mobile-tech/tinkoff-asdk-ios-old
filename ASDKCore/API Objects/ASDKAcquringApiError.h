//
//  ASDKAcquringApiError.h
//  ASDKCore
//
//  Created by Max Zhdanov on 08.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASDKAcquiringResponse.h"

#define kTCSErrorDomain @"ru.tcsbank.asdk"
typedef enum
{
    kASDKApiErrorCodeEmptyCardList = 7
} kASDKApiErrorCode;

@interface ASDKAcquringApiError : NSError

@property (nonatomic, strong) ASDKAcquiringResponse *apiResponse;

+ (ASDKAcquringApiError *)errorWithAcquringResponse:(ASDKAcquiringResponse *)response urlString:(NSString *)urlString parameters:(NSDictionary *)parameters code:(NSInteger)code;

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSDictionary *parameters;

@end
