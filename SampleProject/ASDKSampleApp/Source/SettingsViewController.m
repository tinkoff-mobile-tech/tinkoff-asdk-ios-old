//
//  SettingsViewController.m
//  ASDKSampleApp
//
//  Created by Вячеслав Владимирович Будников on 11.10.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "SettingsViewController.h"
#import "TableViewCellSwitch.h"
#import "TableViewCellSegmentedControl.h"
#import "ASDKTestSettings.h"
#import "PayController.h"
#import <ASDKCore/ASDKCore.h>

typedef NS_ENUM(NSUInteger, SectionType)
{
	SectionTypeTerminal,
	SectionTypePaymentScreen,
	SectionTypeMakeCharge,
	SectionTypeMakeNewCard
};

typedef NS_ENUM(NSUInteger, CellType)
{
	CellTypeKeyboard,
	CellTypeTerminal,
	CellTypeButtonCancel,
	CellTypeButtonPay,
	CellTypeNavBarColor,
	CellTypeMakeCharge,
	CellTypeMakeNewCard,
	CellTypeAddNewCard,
	CellTypeAddNewCardCheckType
};

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *tableViewDataSource;
@property (nonatomic, strong) NSString *addNewCardCheckType;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.addNewCardCheckType = ASDKCardCheckType_NO;
	
	[self setTitle:NSLocalizedString(@"Settings", @"Настройки")];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCellSwitch class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TableViewCellSwitch class])];
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCellSegmentedControl class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TableViewCellSegmentedControl class])];
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:50];
	
	self.tableViewDataSource = @[@{@(SectionTypeTerminal):@[@(CellTypeTerminal)]},
								 @{@(SectionTypePaymentScreen):@[@(CellTypeButtonCancel),@(CellTypeButtonPay),@(CellTypeNavBarColor)]},
								 @{@(SectionTypeMakeCharge):@[@(CellTypeMakeCharge)]},
								 @{@(SectionTypeMakeNewCard):@[@(CellTypeMakeNewCard), @(CellTypeAddNewCard), @(CellTypeAddNewCardCheckType)]}];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"Закрыть")
																	 style:UIBarButtonItemStylePlain
																	target:self
																	action:@selector(closeSelf)];
	
	[self.navigationItem setRightBarButtonItem:cancelButton];
}

- (void)closeSelf
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source helpers

- (NSArray *)cellsSourceForSection:(NSInteger)section
{
	NSDictionary *sectionInfo = [self.tableViewDataSource objectAtIndex:section];
	
	return [sectionInfo objectForKey:[[sectionInfo allKeys] firstObject]];
}

- (SectionType)sectionTypeAtIndex:(NSInteger)section
{
	NSDictionary *sectionInfo = [self.tableViewDataSource objectAtIndex:section];
	
	return [[[sectionInfo allKeys] firstObject] integerValue];
}

- (CellType)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
	NSArray *cellsInSection = [self cellsSourceForSection:indexPath.section];
	
	return [[cellsInSection objectAtIndex:indexPath.row] integerValue];
}
	
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableViewDataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self cellsSourceForSection:section] count];
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *result = @"";
	//
	switch ([self sectionTypeAtIndex:section])
	{
		case SectionTypeTerminal:
			result = NSLocalizedString(@"ActiveTerminal", @"Активный терминал");
			break;
			
		case SectionTypePaymentScreen:
			result = NSLocalizedString(@"PaymentScreenSettings", @"Настройки дизайна");
			break;
			
		default:
			break;
	}
	
	return result;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSString *result = @"";
	//
	switch ([self sectionTypeAtIndex:section])
	{
		case SectionTypeTerminal:
			//
			break;
			
		case SectionTypePaymentScreen:
			result = NSLocalizedString(@"PaymentScreenSettingsDescription", @"Этими настройками можно изменить цвет кнопки Оплатить и её надпись, цвет Панели навигации - NavigationBarColor, navigationBarItemsTextColor, navigationBarStyle. Использовтаь страндартную или свою кнопку 'закрыть' экран оплаты ");
			break;
			
		case SectionTypeMakeCharge:
			result = @"Осуществляет рекуррентный (повторный) платёж — безакцептное списание денежных средств со счета банковской карты Покупателя";
			break;
		
		case SectionTypeMakeNewCard:
			result = @"Оплачивать по реквизитам новой карты.\nВыкл. - оплачивать с последней оплаченой карты.\nВыберите способ проверки карты при привязке.";
			break;
			
		default:
			break;
	}
	
	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	//
	switch ([self cellTypeForIndexPath:indexPath])
	{
  		case CellTypeTerminal:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSegmentedControl class])];
			[(TableViewCellSegmentedControl *)cell setSegments:[ASDKTestSettings testTerminals]];
			[(TableViewCellSegmentedControl *)cell addSegmentedControlValueChangedTarget:self action:@selector(terminalSourceChanged:) forControlEvents:UIControlEventValueChanged];
			[(TableViewCellSegmentedControl *)cell segmentedControlSelectSegment:[ASDKTestSettings testActiveTerminal]];
			break;
			
		case CellTypeButtonCancel:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSwitch class])];
			[(TableViewCellSwitch *)cell setTitle:@"кнопка Отмена"];
			[(TableViewCellSwitch *)cell setSwitchValue:[ASDKTestSettings customButtonCancel]];
			[(TableViewCellSwitch *)cell addSwitchValueChangedTarget:self action:@selector(actionSwitchButtonCancel:) forControlEvents:UIControlEventValueChanged];
			break;
			
		case CellTypeButtonPay:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSwitch class])];
			[(TableViewCellSwitch *)cell setTitle:@"кнопка Оплатить"];
			[(TableViewCellSwitch *)cell setSwitchValue:[ASDKTestSettings customButtonPay]];
			[(TableViewCellSwitch *)cell addSwitchValueChangedTarget:self action:@selector(actionSwitchButtonPay:) forControlEvents:UIControlEventValueChanged];
			break;
			
		case CellTypeNavBarColor:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSwitch class])];
			[(TableViewCellSwitch *)cell setTitle:@"navigationBar"];
			[(TableViewCellSwitch *)cell setSwitchValue:[ASDKTestSettings customNavBarColor]];
			[(TableViewCellSwitch *)cell addSwitchValueChangedTarget:self action:@selector(actionSwitchNavBarColor:) forControlEvents:UIControlEventValueChanged];
			break;
		
		case CellTypeMakeCharge:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSwitch class])];
			[(TableViewCellSwitch *)cell setTitle:@"рекуррентный платёж"];
			[(TableViewCellSwitch *)cell setSwitchValue:[ASDKTestSettings makeCharge]];
			[(TableViewCellSwitch *)cell addSwitchValueChangedTarget:self action:@selector(actionSwitchMakeCharge:) forControlEvents:UIControlEventValueChanged];
			break;

		case CellTypeMakeNewCard:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSwitch class])];
			[(TableViewCellSwitch *)cell setTitle:@"оплачивать по реквизитам"];
			[(TableViewCellSwitch *)cell setSwitchValue:[ASDKTestSettings makeNewCard]];
			[(TableViewCellSwitch *)cell addSwitchValueChangedTarget:self action:@selector(actionSwitchMakeNewCard:) forControlEvents:UIControlEventValueChanged];
			break;
			
		case CellTypeAddNewCard:
			cell = [tableView dequeueReusableCellWithIdentifier:@"addCard"];
			if (cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addCard"];
			}
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			[cell.textLabel setText:@"Добавить новую карту"];
			break;

		case CellTypeAddNewCardCheckType:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSegmentedControl class])];
			[(TableViewCellSegmentedControl *)cell setSegments:@[ASDKCardCheckType_NO, ASDKCardCheckType_3DS, ASDKCardCheckType_HOLD, ASDKCardCheckType_3DSHOLD]];
			[(TableViewCellSegmentedControl *)cell addSegmentedControlValueChangedTarget:self action:@selector(addNewCardCheckTypeChanged:) forControlEvents:UIControlEventValueChanged];
			[(TableViewCellSegmentedControl *)cell segmentedControlSelectSegment:self.addNewCardCheckType];
			break;
			
		default:
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellDefault"];
			break;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([self cellTypeForIndexPath:indexPath] == CellTypeAddNewCard)
	{
		[PayController attachCard:self.addNewCardCheckType additionalData:@{@"Phone":@"+79876543210"} fromViewController:self success:^(ASDKResponseAddCardInit *response) {
			//
		} cancelled:^{
			//
		} error:^(ASDKAcquringSdkError *error) {
			//
		}];
	}
}

- (void)addNewCardCheckTypeChanged:(UISegmentedControl *)sender
{
	switch (sender.selectedSegmentIndex)
	{

		case 1:
			self.addNewCardCheckType = ASDKCardCheckType_3DS;
			break;
			
		case 2:
			self.addNewCardCheckType = ASDKCardCheckType_HOLD;
			break;
			
		case 3:
			self.addNewCardCheckType = ASDKCardCheckType_3DSHOLD;
			break;
			
		case 0:
		default:
			self.addNewCardCheckType = ASDKCardCheckType_NO;
			break;
	}
}

- (void)terminalSourceChanged:(UISegmentedControl *)sender
{
//	NSLog(@"%@", @(sender.selectedSegmentIndex));
	[ASDKTestSettings setActiveTestTerminal:[sender titleForSegmentAtIndex:sender.selectedSegmentIndex]];
}

- (void)actionSwitchButtonCancel:(UISegmentedControl *)sender
{
	[ASDKTestSettings setCustomButtonCancel:![ASDKTestSettings customButtonCancel]];
}

- (void)actionSwitchButtonPay:(UISegmentedControl *)sender
{
	[ASDKTestSettings setCustomButtonPay:![ASDKTestSettings customButtonPay]];
}

- (void)actionSwitchNavBarColor:(UISegmentedControl *)sender
{
	[ASDKTestSettings setCustomNavBarColor:![ASDKTestSettings customNavBarColor]];
}

- (void)actionSwitchMakeCharge:(UISegmentedControl *)sender
{
	[ASDKTestSettings setMakeCharge:![ASDKTestSettings makeCharge]];
}

- (void)actionSwitchMakeNewCard:(UISegmentedControl *)sender
{
	[ASDKTestSettings setMakeNewCard:![ASDKTestSettings makeNewCard]];
}

@end
