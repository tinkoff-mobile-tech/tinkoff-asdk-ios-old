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

+ (void)buyItemWithName:(NSString *)name
            description:(NSString *)description
                 amount:(NSNumber *)amount
     fromViewController:(UIViewController *)viewController
                success:(void (^)(NSNumber *paymentId))onSuccess
              cancelled:(void (^)())onCancelled
                  error:(void(^)(ASDKAcquringSdkError *error))onError
{
    //NSString *publicKeyPath = [[NSBundle mainBundle] pathForResource:kASDKTestPublicKeyName ofType:@"pem"];
    //ASDKStringKeyCreator *stringKeyCreator = [[ASDKStringKeyCreator alloc] initWithPublicKeyPath:publicKeyPath];
	
	ASDKStringKeyCreator *stringKeyCreator = [[ASDKStringKeyCreator alloc] initWithPublicKeyString:[ASDKTestSettings testPublicKey]];
	
    ASDKAcquiringSdk *acquiringSdk = [ASDKAcquiringSdk acquiringSdkWithTerminalKey:[ASDKTestSettings testActiveTerminal]
                                                                          password:[ASDKTestSettings testTerminalPassword]
                                                               publicKeyDataSource:stringKeyCreator];
    
    [acquiringSdk setDebug:YES];
    [acquiringSdk setLogger:nil];
    
    ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter paymentFormStarterWithAcquiringSdk:acquiringSdk];
    
    double randomOrderId = arc4random()%10000000;
    NSString *customerKey = @"testCustomerKey1@gmail.com";
//    NSString *customerKey = @"hockeyCustomerKey@gmail.com";
    
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
                                              customKeyboard:YES
                                                 customerKey:customerKey
                                                     success:^(NSNumber *paymentId)
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
         
         onError(error);
     }];
}

@end
