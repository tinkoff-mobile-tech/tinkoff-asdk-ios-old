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

@interface ASDKCardRequisites: NSObject <ASDKAcquiringSdkCardRequisites>

@property (nonatomic, copy) NSString *scanedCardNumber;
@property (nonatomic, copy) NSString *scanedCardExpiredDate;

@end

@implementation ASDKCardRequisites

- (NSString *)cardExpireDate
{
	return self.scanedCardExpiredDate;
}

- (NSString *)cardNumber
{
	return self.scanedCardNumber;
}

@end

@interface ASDKCardIOScanner () <CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) ASDKCardRequisites *cardRequisites;
@property (nonatomic, strong) void (^successBlock)(id<ASDKAcquiringSdkCardRequisites> cardRequisites);
@property (nonatomic, strong) void (^cancelBlock)(void);

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
    [cardScaner setDisableManualEntryButtons:NO];
	[cardScaner setScanExpiry:YES];
	[cardScaner setCollectExpiry:YES];
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
    if (self.successBlock)
    {
		self.cardRequisites = [[ASDKCardRequisites alloc] init];
		self.cardRequisites.scanedCardNumber = info.cardNumber;
		if (info.expiryYear > 0 && info.expiryMonth > 0)
		{
			self.cardRequisites.scanedCardExpiredDate = [NSString stringWithFormat:@"%02lu/%02lu", (unsigned long)info.expiryMonth, (unsigned long)(info.expiryYear - 2000)];
		}

        self.successBlock(self.cardRequisites);
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

- (void)scanCardSuccess:(void (^)(id<ASDKAcquiringSdkCardRequisites> cardRequisites))success
                failure:(void (^)(ASDKAcquringSdkError *error))failure
                 cancel:(void (^)(void))cancel
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
