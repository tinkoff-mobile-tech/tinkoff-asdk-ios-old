//
//  TableViewCellSegmentedControll.h
//  ASDKSampleApp
//
//  Created by Вячеслав Владимирович Будников on 11.10.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCellSegmentedControl : UITableViewCell

- (void)setSegments:(NSArray *)segments;
- (void)addSegmentedControlValueChangedTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)segmentedControlSelectSegment:(NSString *)title;

@end
