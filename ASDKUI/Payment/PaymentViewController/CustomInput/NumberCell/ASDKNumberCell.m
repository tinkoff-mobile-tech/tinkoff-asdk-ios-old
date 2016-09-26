//
//  ASDKNumberCell.m
//  ASDKUI
//
// Copyright (c) 2016 TCS Bank
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ASDKNumberCell.h"
#import "ASDKDesign.h"

@interface ASDKNumberCell ()

@property (weak, nonatomic) IBOutlet UIView *bottomSeparator;
@property (weak, nonatomic) IBOutlet UIView *rightSeparator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSeparatorHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSeparatorWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSeparatorTrailing;

@end

@implementation ASDKNumberCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	
    self.bottomSeparatorHeight.constant = 1.0f / [UIScreen mainScreen].scale;
    self.rightSeparatorWidth.constant = 1.0f / [UIScreen mainScreen].scale;
    self.bottomSeparatorTrailing.constant /= 2;
    
    [self.bottomSeparator setBackgroundColor:[ASDKDesign colorN4Separator]];
    [self.rightSeparator setBackgroundColor:[ASDKDesign colorN4Separator]];
}

@end
