//
//  ASDKEmptyTableViewCell.m
//  ASDKUI
//
//  Created by v.budnikov on 13.09.17.
//  Copyright © 2017 TCS Bank. All rights reserved.
//

#import "ASDKEmptyTableViewCell.h"
#import "ASDKDesign.h"

@implementation ASDKEmptyTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

	[self.contentView setBackgroundColor:[ASDKDesign colorTableViewBackground]];
}

@end
