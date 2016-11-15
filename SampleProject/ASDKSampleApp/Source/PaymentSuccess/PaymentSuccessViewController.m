//
//  PaymentSuccessViewController.m
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "PaymentSuccessViewController.h"
#import "LocalConstants.h"

NSString *const kCurrencyRubSymbol = @"₽";

@interface PaymentSuccessViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *paymentSuccessImageView;
@property (weak, nonatomic) IBOutlet UILabel *paymentSuccessLabel;

@end

@implementation PaymentSuccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"OnlineShop", @"Интернет магазин");
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Готово")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(closeSelf)];
    
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self updateAmountLabel];
}

- (void)closeSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAmount:(NSNumber *)amount
{
    _amount = amount;
    
    [self updateAmountLabel];
}

- (void)updateAmountLabel
{
    NSString *amountWithCurrency = [NSString stringWithFormat:@"%.2f %@", self.amount.doubleValue, kCurrencyRubSymbol];
    NSString *amountFull = [NSString stringWithFormat:NSLocalizedString(@"BuyingSuccessful", @"Покупка на сумму XXX прошла успешно"), amountWithCurrency];
    
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] initWithString:amountFull];
    NSRange range = [resultString.string rangeOfString:amountWithCurrency];
    [resultString addAttribute:NSForegroundColorAttributeName value:kMainBlueColor range:range];
    
    self.paymentSuccessLabel.attributedText = resultString;
}

@end
