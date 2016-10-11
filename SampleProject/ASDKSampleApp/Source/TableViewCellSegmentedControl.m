//
//  TableViewCellSegmentedControll.m
//  ASDKSampleApp
//
//  Created by Вячеслав Владимирович Будников on 11.10.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import "TableViewCellSegmentedControl.h"

@interface TableViewCellSegmentedControl ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
	
@end

@implementation TableViewCellSegmentedControl

- (void)awakeFromNib
{
    [super awakeFromNib];
	
    // Initialization code
}

- (void)addSegmentedControlValueChangedTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.segmentedControl addTarget:target action:action forControlEvents:controlEvents];
}
	
@end
