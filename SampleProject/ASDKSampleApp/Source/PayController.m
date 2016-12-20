//
//  PayController.m
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 12.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "PayController.h"

#import "ASDKTestSettings.h"
#import <ASDKUI/ASDKUI.h>

#import "ASDKCardIOScanner.h"

#import "PaymentSuccessViewController.h"

@implementation PayController

+ (ASDKPaymentFormStarter *)paymentFormStarter
{
	ASDKStringKeyCreator *stringKeyCreator = [[ASDKStringKeyCreator alloc] initWithPublicKeyString:[ASDKTestSettings testPublicKey]];
	ASDKAcquiringSdk *acquiringSdk = [ASDKAcquiringSdk acquiringSdkWithTerminalKey:[ASDKTestSettings testActiveTerminal]
																		   payType:nil//@"О"//@"T"
																		  password:[ASDKTestSettings testTerminalPassword]
															   publicKeyDataSource:stringKeyCreator];
	
	[acquiringSdk setDebug:YES];
	[acquiringSdk setLogger:nil];
	
	return [ASDKPaymentFormStarter paymentFormStarterWithAcquiringSdk:acquiringSdk];
}

+ (NSString *)customerKey
{
	return @"testCustomerKey1@gmail.com";
}

+ (void)buyItemWithName:(NSString *)name
            description:(NSString *)description
                 amount:(NSNumber *)amount
  additionalPaymentData:(NSDictionary *)data
     fromViewController:(UIViewController *)viewController
                success:(void (^)(NSString *paymentId))onSuccess
              cancelled:(void (^)())onCancelled
                  error:(void(^)(ASDKAcquringSdkError *error))onError
{
	ASDKPaymentFormStarter *paymentFormStarter = [PayController paymentFormStarter];

    double randomOrderId = arc4random()%10000000;
	
//Настройка дизайна
//    ASDKDesignConfiguration *designConfiguration = [[ASDKDesignConfiguration alloc] init];
//    [designConfiguration setNavigationBarColor:[UIColor orangeColor] navigationBarItemsTextColor:[UIColor darkGrayColor] navigationBarStyle:UIBarStyleDefault];
//    [designConfiguration setPayButtonColor:[UIColor greenColor] payButtonPressedColor:[UIColor blueColor] payButtonTextColor:[UIColor whiteColor]];
//    paymentFormStarter.designConfiguration = designConfiguration;
//Настройка сканнера карт

    paymentFormStarter.cardScanner = [ASDKCardIOScanner scanner];
    
    [paymentFormStarter presentPaymentFormFromViewController:viewController
                                                     orderId:[NSNumber numberWithDouble:randomOrderId].stringValue
                                                      amount:amount
                                                       title:name
                                                 description:description
                                                      cardId:nil
                                                       email:nil 
                                                 customerKey:[PayController customerKey]
									   additionalPaymentData:data
                                                     success:^(NSString *paymentId)

     {
         PaymentSuccessViewController *vc = [[PaymentSuccessViewController alloc] init];
         vc.amount = amount;
         UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
         
         [viewController presentViewController:nc animated:YES completion:nil];
         
         onSuccess(paymentId);
     }
                                                   cancelled:^
     {
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CanceledPayment", @"Оплата отменена") message:nil preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *cancelAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"Close", @"Закрыть")
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *action)
                                        {
                                            [alertController dismissViewControllerAnimated:YES completion:nil];
                                        }];
         
         [alertController addAction:cancelAction];
         
         [viewController presentViewController:alertController animated:YES completion:nil];

         onCancelled();
     }
                                                       error:^(ASDKAcquringSdkError *error)
     {
		 
		 NSString *alertTitle = error.errorMessage ? error.errorMessage : @"Ошибка";
		 NSString *alertDetails = error.errorDetails ? error.errorDetails : error.userInfo[kASDKStatus];
		 
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:alertDetails preferredStyle:UIAlertControllerStyleAlert];
         
         UIAlertAction *cancelAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"Close", @"Закрыть")
                                        style:UIAlertActionStyleCancel
                                        handler:^(UIAlertAction *action)
                                        {
                                            [alertController dismissViewControllerAnimated:YES completion:nil];
                                        }];
         
         [alertController addAction:cancelAction];
         
         [viewController presentViewController:alertController animated:YES completion:nil];
         
         onError(error);
     }];
}

+ (BOOL)isPayWithAppleAvailable
{
	return [ASDKPaymentFormStarter isPayWithAppleAvailable];
}

+ (void)buyWithApplePayAmount:(NSNumber *)amount
				  description:(NSString *)description
						email:(NSString *)email
			  appleMerchantId:(NSString *)appleMerchantId
			  shippingMethods:(NSArray<PKShippingMethod *> *)shippingMethods
			  shippingContact:(PKContact *)shippingContact
		additionalPaymentData:(NSDictionary *)data
		   fromViewController:(UIViewController *)viewController
					  success:(void (^)(NSString *paymentId))onSuccess
					cancelled:(void (^)())onCancelled
						error:(void(^)(ASDKAcquringSdkError *error))onError
{
	ASDKPaymentFormStarter *paymentFormStarter = [PayController paymentFormStarter];
	[paymentFormStarter payWithApplePayFromViewController:viewController
												   amount:amount
												  orderId:[NSNumber numberWithDouble:(arc4random()%10000000)].stringValue
											  description:description
											  customerKey:[PayController customerKey]
												sendEmail:([email length] > 0)
													email:email
										  appleMerchantId:appleMerchantId
										  shippingMethods:shippingMethods
										  shippingContact:shippingContact
									additionalPaymentData:data
												  success:^(NSString *paymentId) {
													  PaymentSuccessViewController *vc = [[PaymentSuccessViewController alloc] init];
													  vc.amount = amount;
													  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
													  
													  [viewController presentViewController:nc animated:YES completion:nil];
													  
													  onSuccess(paymentId);
												  }
												cancelled:^{
													  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CanceledPayment", @"Оплата отменена") message:nil preferredStyle:UIAlertControllerStyleAlert];
													  
													  UIAlertAction *cancelAction = [UIAlertAction
																					 actionWithTitle:NSLocalizedString(@"Close", @"Закрыть")
																					 style:UIAlertActionStyleCancel
																					 handler:^(UIAlertAction *action)
																					 {
																						 [alertController dismissViewControllerAnimated:YES completion:nil];
																					 }];
													  
													  [alertController addAction:cancelAction];
													  
													  [viewController presentViewController:alertController animated:YES completion:nil];
													  
													  onCancelled();
												  }
													error:^(ASDKAcquringSdkError *error) {
														if (error)
														{
														  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.errorMessage message:error.errorDetails preferredStyle:UIAlertControllerStyleAlert];
														  
														  UIAlertAction *cancelAction = [UIAlertAction
																						 actionWithTitle:NSLocalizedString(@"Close", @"Закрыть")
																						 style:UIAlertActionStyleCancel
																						 handler:^(UIAlertAction *action)
																						 {
																							 [alertController dismissViewControllerAnimated:YES completion:nil];
																						 }];
														  
														  [alertController addAction:cancelAction];
														  
														  [viewController presentViewController:alertController animated:YES completion:nil];
														}

													  onError(error);
												  }];
	//
}

@end
