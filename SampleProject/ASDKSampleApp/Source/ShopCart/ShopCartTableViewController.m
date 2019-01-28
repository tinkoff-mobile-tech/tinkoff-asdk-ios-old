//
//  ShopCartTableViewController.m
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "ShopCartTableViewController.h"
#import "ShopCartCell.h"
#import "BookItem.h"
#import "ShopCart.h"

#import "PayController.h"

#import "LocalConstants.h"

@interface ShopCartTableViewController ()
{
    double _total;
}

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, weak) IBOutlet UILabel *totalLabel;
@property (nonatomic, weak) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonApplePay;

@property (weak, nonatomic) IBOutlet UIView *bottomContainerView;
@property (weak, nonatomic) IBOutlet UILabel *labelContentStatus;

@end

@implementation ShopCartTableViewController

#pragma mark - Init

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
    self.title = NSLocalizedString(@"Bag", @"Корзина");
    
    [self.myTableView setRowHeight:117.0f];
    
    [self.myTableView registerNib:[UINib nibWithNibName:NSStringFromClass([ShopCartCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([ShopCartCell class])];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf)]];
    
    [self.payButton.layer setCornerRadius:3.0f];
	[self.payButton setTitle:NSLocalizedString(@"Pay", @"ОПЛАТИТЬ") forState:UIControlStateNormal];
	
    self.items = [[ShopCart sharedInstance] allItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShopCartUpdate) name:kShopCartUpdated object:nil];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self updateTotal];
    [self updateTotalLabel];
    
    self.bottomContainerView.backgroundColor = kMainBlueColor;
	
	[self.buttonApplePay setEnabled:[PayController isPayWithAppleAvailable]];
	[self handleShopCartUpdate];
}

- (void)handleShopCartUpdate
{
    [self updateTotal];
    [self updateTotalLabel];
	
	if (_items.count == 0)
	{
		[self.labelContentStatus setHidden:NO];
		[self.labelContentStatus setText:NSLocalizedString(@"BagIsEmpty", @"Корзина пуста")];
	}
	else
	{
		[self.labelContentStatus setHidden:YES];
	}
	
    [self.myTableView reloadData];
}

- (void)updateTotalLabel
{
    NSString *amountAsString = [[NSString stringWithFormat:@"%.2f ₽",_total]  stringByReplacingOccurrencesOfString:@"." withString:@","];
    self.totalLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Total", @"Итого"), amountAsString];
}

- (void)updateTotal
{
    double total = 0.0;
    
    for (BookItem *item in self.items)
    {
        total += item.cost.doubleValue;
    }
    
    _total = total;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = NSStringFromClass([ShopCartCell class]);
    ShopCartCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[ShopCartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 11.0f;//.01f;
}

- (void)configureCell:(ShopCartCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    BookItem *currentItem = _items[indexPath.row];
    
    [cell setBookItem:currentItem];
}

#pragma mark - Table view Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Actions

- (void)dismissSelf
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)validateSelf
{
    if (_items.count == 0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BagIsEmpty", @"Корзина пуста") message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Close", @"Закрыть")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           [alertController dismissViewControllerAnimated:YES completion:nil];
                                       }];
        
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)buyAction:(id)sender
{
    if (![self validateSelf])
    {
        return;
    }
    
    #warning TITLE & DESCRIPTION!!!
    
    [PayController buyItemWithName:NSLocalizedString(@"Books", @"Книги")
                       description:NSLocalizedString(@"ALotOfBooks", @"Много книг")
							amount:[NSNumber numberWithDouble:_total]
						 recurrent:NO
						makeCharge:NO
			 additionalPaymentData:nil
					   receiptData:nil
                fromViewController:self
                           success:^(ASDKPaymentInfo *paymentInfo)
     {
         NSLog(@"%@",paymentInfo.paymentId);
         
         [[ShopCart sharedInstance] deleteAllItems];
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

- (IBAction)buttonActionApplePay:(UIButton *)sender
{
	
}

@end
