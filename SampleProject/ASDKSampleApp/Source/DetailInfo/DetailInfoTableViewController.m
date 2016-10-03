//
//  DetailInfoTableViewController.m
//  ASDKSampleApp
//
//  Created by spb-EOrlova on 11.02.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "DetailInfoTableViewController.h"
#import "BookItemCell.h"
#import "ShopCartTableViewController.h"
#import "ShopCart.h"

#import "PayController.h"

#import "LocalConstants.h"

@interface DetailInfoTableViewController ()

@property (nonatomic, strong) BookItem *item;
@property (nonatomic, strong) BookItemCell *detailInfoCell;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIButton *buttonApplePay;
@property (nonatomic, weak) IBOutlet UILabel *itemCostLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomContainerView;

@end

@implementation DetailInfoTableViewController

- (instancetype)initWithItem:(BookItem *)item
{
    self = [super init];
    
    if (self)
    {
        _item = item;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Интернет магазин";
    
    [self.myTableView registerNib:[UINib nibWithNibName:NSStringFromClass([BookItemCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([BookItemCell class])];
    
    UIBarButtonItem *shopCartButton = [[UIBarButtonItem alloc] initWithTitle:@"Корзина"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(openShopCart:)];
    
    [self.navigationItem setRightBarButtonItem:shopCartButton];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.buyButton.layer setCornerRadius:3.0f];
    [self.addToCartButton.layer setCornerRadius:3.0f];
    
    [self.buyButton addTarget:self action:@selector(buyItem) forControlEvents:UIControlEventTouchUpInside];
    [self.addToCartButton addTarget:self action:@selector(addItemToCart) forControlEvents:UIControlEventTouchUpInside];
    
    [self.itemCostLabel setText:[_item amountAsString]];
    
    self.bottomContainerView.backgroundColor = kMainBlueColor;
	
	[self.buttonApplePay setEnabled:[PayController isPayWithAppleAvailable]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BookItemCell *)detailInfoCell
{
    if (!_detailInfoCell)
    {
        _detailInfoCell = [BookItemCell cell];
        _detailInfoCell.bookItem = _item;
        [_detailInfoCell.itemImageView setImage:_item.cover];
        [_detailInfoCell.itemTitleLabel setText:_item.title];
        [_detailInfoCell.itemSubtitleLabel setText:_item.author];
        [_detailInfoCell.itemDescriptionLabel setText:_item.bookDescription];
        [_detailInfoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        _detailInfoCell.shouldHideBuySection = YES;
    }
    
    return _detailInfoCell;
}

- (IBAction)openShopCart:(id)sender
{
    ShopCartTableViewController *shopCartController = [[ShopCartTableViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:shopCartController];
    
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self detailInfoCell] cellHeightWithWidth:self.view.frame.size.width-30];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self detailInfoCell];
}

#pragma mark - Actions

- (void)addItemToCart
{
    [[ShopCart sharedInstance] addItem:self.item.copy];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Товар добавлен в корзину" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Закрыть"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)buyItem
{
    [PayController buyItemWithName:self.item.title
                       description:self.item.bookDescription
                            amount:self.item.cost
                fromViewController:self
                           success:^(NSString *paymentId)
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

- (IBAction)buttonActionApplePay:(UIButton *)sender
{
	if ([PayController isPayWithAppleAvailable])
	{
		PKShippingMethod *method1 = [[PKShippingMethod alloc] init];
		method1.identifier = @"method1";
		method1.detail = @"ShippingMethod";

		[PayController buyWithApplePayAmount:self.item.cost
								 description:self.item.title
									recurent:YES
									   email:@"test@gmail.com"
							 appleMerchantId:@"merchant.tcsbank.ApplePayTestMerchantId"
							 shippingMethods:@[method1]//(NSArray<PKShippingMethod *> *)
									 contact:nil
						  fromViewController:self
									 success:^(NSString *paymentId) { NSLog(@"%@",paymentId); }
								   cancelled:^{ NSLog(@"Canceled"); }
									   error:^(ASDKAcquringSdkError *error) {  NSLog(@"%@",error); }];
		
		
//		[PayController buyWithApplePayItemWithName:self.item.title
//									   description:self.item.bookDescription
//											amount:self.item.cost
//								   appleMerchantId:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AAPLEmporiumBundlePrefix"]
//								   shippingMethods:nil//(NSArray<PKShippingMethod *> *)shippingMethods
//										   contact:nil//(PKContact *)contact
//								fromViewController:self
//										   success:^(NSString *paymentId) {  NSLog(@"%@",paymentId); }
//										 cancelled:^{ NSLog(@"Canceled");  }
//											 error:^(ASDKAcquringSdkError *error) {  NSLog(@"%@",error); }];
	}
}

@end
