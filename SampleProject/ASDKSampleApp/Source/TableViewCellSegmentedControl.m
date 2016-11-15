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

- (void)setSegments:(NSArray *)segments
{
	[self.segmentedControl removeAllSegments];
	
	for (NSUInteger i = 0; i < [segments count]; i++)
	{
		[self.segmentedControl insertSegmentWithTitle:[segments objectAtIndex:i] atIndex:i animated:NO];
	}
	
	[self.segmentedControl setSelectedSegmentIndex:0];
}

- (void)segmentedControlSelectSegment:(NSString *)title
{
	[self.segmentedControl setSelectedSegmentIndex:0];
	
	for (NSUInteger index = 0; index < [self.segmentedControl numberOfSegments]; index++)
	{
		if ([[self.segmentedControl titleForSegmentAtIndex:index] isEqualToString:title])
		{
			[self.segmentedControl setSelectedSegmentIndex:index];
			break;
		}
	}
}

- (void)addSegmentedControlValueChangedTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
	[self.segmentedControl addTarget:target action:action forControlEvents:controlEvents];
}
	
@end
