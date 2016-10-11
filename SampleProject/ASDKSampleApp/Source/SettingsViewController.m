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

typedef NS_ENUM(NSUInteger, SectionType)
{
	SectionTypeKeyboard,
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
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCellSwitch class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TableViewCellSwitch class])];
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TableViewCellSegmentedControl class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:NSStringFromClass([TableViewCellSegmentedControl class])];

	self.tableViewDataSource = @[@{@(SectionTypeKeyboard):@[@(CellTypeKeyboard)]},
								 @{@(SectionTypeTerminal):@[@(CellTypeTerminal)]}];
	
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	//
	switch ([self cellTypeForIndexPath:indexPath])
	{
  		case CellTypeTerminal:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSegmentedControl class])];
			
			break;
			
		case CellTypeKeyboard:
			cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TableViewCellSwitch class])];
			[(TableViewCellSwitch *)cell setTitle:@"Использовать системную клавиатуру"];
			[(TableViewCellSwitch *)cell addSwitchValueChangedTarget:self action:@selector(useSystemKeyboard:) forControlEvents:UIControlEventValueChanged];
			break;
			
  		default:
			break;
	}
	
    return cell;
}


- (void)useSystemKeyboard:(UISwitch *)sender
{
	
}

- (void)terminalSourceChanged:(UISegmentedControl *)sender
{
	
}

@end
