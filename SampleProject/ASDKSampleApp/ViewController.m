//
//  ViewController.m
//  ASDKSampleApp
//
//  Created by Max Zhdanov on 05.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "ViewController.h"
#import <ASDKCore/ASDKCore.h>
#import <ASDKUI/ASDKUI.h>

#import "ASDKCardIOScanner.h"

#import "ASDKTestKeys.h"


@interface ViewController ()

@property (nonatomic, strong) ASDKCardIOScanner *scannerObject;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testAction:(id)sender
{
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:kASDKTestPublicKeyName ofType:@"pem"];
    
    ASDKPaymentFormStarter *paymentFormStarter = [ASDKPaymentFormStarter paymentFormStarterWithTerminalKey:kASDKTestTerminalKey
                                                                           password:kASDKTestPassword
                                                                      publicKeyPath:keyPath
                                                                              debug:YES
                                                                             logger:nil
                                                                        cardScanner:[ASDKCardIOScanner scanner]];
    
    double randomPaymentId = arc4random()%1000000;

    [paymentFormStarter presentPaymentFormFromViewController:self
                                                     orderId:[NSNumber numberWithDouble:randomPaymentId].stringValue
                                                      amount:@123
                                                       title:@"Testik"
                                                 description:nil
                                                      cardId:nil
                                                       email:nil
                                              customKeyboard:NO
                                                     success:^(NSNumber *paymentId)
     {
         NSLog(@"%@",paymentId);
     }
                                                   cancelled:^
     {
         NSLog(@"Canceled");
     }
                                                       error:^(ASDKAcquringSdkError *error)
     {
         NSLog(@"%@",error);
     }];
}

@end
