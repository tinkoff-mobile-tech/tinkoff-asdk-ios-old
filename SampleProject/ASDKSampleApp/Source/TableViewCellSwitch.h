//
//  TableViewCellSwitch.h
//  ASDKSampleApp
//
//  Created by Вячеслав Владимирович Будников on 11.10.16.
//  Copyright © 2016 TCS Bank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCellSwitch : UITableViewCell

- (void)setTitle:(NSString *)title;
- (void)setSwitchValue:(BOOL)value;
- (void)addSwitchValueChangedTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
