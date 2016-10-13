//
//  TableViewCellSwitch.m
//  ASDKSampleApp
//
//  Created by Вячеслав Владимирович Будников on 11.10.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "TableViewCellSwitch.h"

@interface TableViewCellSwitch ()

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UISwitch *buttonSwitch;
	
@end

@implementation TableViewCellSwitch

- (void)awakeFromNib
{
    [super awakeFromNib];
	
	//
}

- (void)setTitle:(NSString *)title
{
	[self.labelTitle setText:title];
}

- (void)setSwitchValue:(BOOL)value
{
	[self.buttonSwitch setOn:value];
}

- (void)addSwitchValueChangedTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.buttonSwitch addTarget:target action:action forControlEvents:controlEvents];
}
	
@end
