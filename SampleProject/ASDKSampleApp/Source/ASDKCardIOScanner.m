//
//  TestScanClass.m
//  ASDKSampleApp
//
//  Created by Макс Жданов on 07.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "CardIO.h"
#import "ASDKCardIOScanner.h"

@interface ASDKCardIOScanner () <CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) void (^successBlock)(NSString *cardNumber);
@property (nonatomic, strong) void (^cancelBlock)();

@end

@implementation ASDKCardIOScanner

+ (instancetype)scanner
{
    ASDKCardIOScanner *scanner = [[ASDKCardIOScanner alloc] init];
    
    return scanner;
}

- (void)openCardScaner
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (granted)
            {
                CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
                scanViewController.disableBlurWhenBackgrounding = YES;
                scanViewController.navigationBarStyle = UIBarStyleBlack;
                [self setupCardScaner:scanViewController];
                
                UIViewController *topVc = [ASDKCardIOScanner topMostController];
                [topVc presentViewController:scanViewController animated:YES completion:nil];
            }
            else
            {
                //ALERT
            }
        });
    }];
}

- (void)setupCardScaner:(CardIOPaymentViewController *)cardScaner
{
    [cardScaner setKeepStatusBarStyle:YES];
    [cardScaner setSuppressScanConfirmation:YES];
    [cardScaner setUseCardIOLogo:YES];
    [cardScaner setDisableManualEntryButtons:YES];
    [cardScaner setCollectExpiry:NO];
    [cardScaner setCollectCVV:NO];
}

+ (UIViewController*)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    NSString *cardNumber = info.cardNumber;
    
    if (self.successBlock)
    {
        self.successBlock(cardNumber);
    }
    
    [self closePaymentViewController:paymentViewController];
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    if (self.cancelBlock)
    {
        self.cancelBlock();
    }
    
    [self closePaymentViewController:paymentViewController];
}

- (void)scanCardSuccess:(void (^)(NSString *cardNumnber))success
                failure:(void (^)(ASDKAcquringSdkError *error))failure
                 cancel:(void (^)())cancel
{
    self.successBlock = success;
    self.cancelBlock = cancel;
    
    [self openCardScaner];
}

- (void)closePaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
