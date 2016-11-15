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
#import <PassKit/PassKit.h>

@interface PayController : NSObject

+ (void)buyItemWithName:(NSString *)name
            description:(NSString *)description
                 amount:(NSNumber *)amount
     fromViewController:(UIViewController *)viewController
                success:(void (^)(NSString *paymentId))onSuccess
              cancelled:(void (^)())onCancelled
                  error:(void(^)(ASDKAcquringSdkError *error))onError;

+ (BOOL)isPayWithAppleAvailable;
+ (void)buyWithApplePayAmount:(NSNumber *)amount
				  description:(NSString *)description
						email:(NSString *)email
			  appleMerchantId:(NSString *)appleMerchantId
			  shippingMethods:(NSArray<PKShippingMethod *> *)shippingMethods
			  shippingContact:(PKContact *)shippingContact
		   fromViewController:(UIViewController *)viewController
					  success:(void (^)(NSString *paymentId))onSuccess
					cancelled:(void (^)())onCancelled
						error:(void(^)(ASDKAcquringSdkError *error))onError;

@end
