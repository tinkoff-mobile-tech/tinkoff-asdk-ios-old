//
//  ASDKAcquringApiError.h
//  ASDKCore
//
//  Created by Max Zhdanov on 03.02.16.
//  Copyright © 2016 TCS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASDKAcquringApiError : NSError

+ (ASDKAcquringApiError *)errorWithMessage:(NSString *)message details:(NSString *)details code:(NSInteger)code;

- (NSString *)errorMessage;
- (NSString *)errorDetails;

@end
