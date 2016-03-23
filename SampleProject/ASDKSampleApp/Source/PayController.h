//
//  PayController.h
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 12.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ASDKCore/ASDKCore.h>

@interface PayController : NSObject

+ (void)buyItemWithName:(NSString *)name
            description:(NSString *)description
                 amount:(NSNumber *)amount
     fromViewController:(UIViewController *)viewController
                success:(void (^)(NSNumber *paymentId))onSuccess
              cancelled:(void (^)())onCancelled
                  error:(void(^)(ASDKAcquringSdkError *error))onError;

@end
