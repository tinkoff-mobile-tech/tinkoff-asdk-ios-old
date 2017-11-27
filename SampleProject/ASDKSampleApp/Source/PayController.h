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
			  recurrent:(BOOL)recurrent
			 makeCharge:(BOOL)makeCharge
  additionalPaymentData:(NSDictionary *)data
			receiptData:(NSDictionary *)receiptData
     fromViewController:(UIViewController *)viewController
                success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
              cancelled:(void (^)(void))onCancelled
                  error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (void)chargeWithRebillId:(NSNumber *)rebillId
					amount:(NSNumber *)amount
			   description:(NSString *)description
	 additionalPaymentData:(NSDictionary *)data
			   receiptData:(NSDictionary *)receiptData
		fromViewController:(UIViewController *)viewController
				   success:(void (^)(ASDKPaymentInfo *paymentInfo))onSuccess
					 error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (BOOL)isPayWithAppleAvailable;
+ (void)buyWithApplePayAmount:(NSNumber *)amount
				  description:(NSString *)description
						email:(NSString *)email
			  appleMerchantId:(NSString *)appleMerchantId
			  shippingMethods:(NSArray<PKShippingMethod *> *)shippingMethods
			  shippingContact:(PKContact *)shippingContact
	   shippingEditableFields:(PKAddressField)shippingEditableFields
					recurrent:(BOOL)recurrent
		additionalPaymentData:(NSDictionary *)data
				  receiptData:(NSDictionary *)receiptData
		   fromViewController:(UIViewController *)viewController
					  success:(void (^)(ASDKPaymentInfo *paymentIfo))onSuccess
					cancelled:(void (^)(void))onCancelled
						error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (void)checkStatusTransaction:(NSString *)paymentId
	   fromViewController:(UIViewController *)viewController
				  success:(void (^)(ASDKPaymentStatus status))onSuccess
					error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (void)refundTransaction:(NSString *)paymentId
	   fromViewController:(UIViewController *)viewController
				  success:(void (^)(void))onSuccess
					error:(void (^)(ASDKAcquringSdkError *error))onError;

+ (void)attachCard:(NSString *)cardCheckType additionalData:(NSDictionary *)data fromViewController:(UIViewController *)viewController
		   success:(void (^)(ASDKResponseAddCardInit *response))onSuccess
		 cancelled:(void (^)(void))onCancelled
			 error:(void (^)(ASDKAcquringSdkError *error))onError;

@end
