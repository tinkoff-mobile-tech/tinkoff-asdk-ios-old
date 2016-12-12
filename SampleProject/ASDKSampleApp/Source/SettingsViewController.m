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

typedef NS_ENUM(NSUInteger, SectionType)
{
	SectionTypeTerminal
};

typedef NS_ENUM(NSUInteger, CellType)
{
	CellTypeKeyboard,
	CellTypeTerminal
};

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *tableViewDataSource;
	
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self setTitle:NSLocalizedString(@"Settings", @"Настройки")];
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCellSwitch class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TableViewCellSwitch class])];
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCellSegmentedControl class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TableViewCellSegmentedControl class])];
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:50];
	
	self.tableViewDataSource = @[@{@(SectionTypeTerminal):@[@(CellTypeTerminal)]}];
	
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

  		default:
			break;
	}
	
    return cell;
}

- (void)terminalSourceChanged:(UISegmentedControl *)sender
{
	NSLog(@"%@", @(sender.selectedSegmentIndex));
	[ASDKTestSettings setActiveTestTerminal:[sender titleForSegmentAtIndex:sender.selectedSegmentIndex]];
}

@end
