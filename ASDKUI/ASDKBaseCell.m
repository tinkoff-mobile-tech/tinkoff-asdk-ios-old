//
//  ASDKBaseCell.m
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


#import "ASDKBaseCell.h"
#import "ASDKUtils.h"
#import "ASDKDesign.h"

#define kSeparatorLineHeight		1.0f / [[UIScreen mainScreen] scale]

@interface ASDKBaseCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *customTopSeparatorHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *customBottomSeparatorHeight;

@property (nonatomic, weak) IBOutlet UIImageView *customTopSeparator;
@property (nonatomic, weak) IBOutlet UIImageView *customBottomSeparator;

@end

@implementation ASDKBaseCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.shouldShowBottomSeparator = YES;
    self.shouldShowTopSeparator = NO;
    
    [self.customTopSeparator setImage:[ASDKUtils imageFromColor:[ASDKDesign colorN4Separator]]];
    [self.customBottomSeparator setImage:[ASDKUtils imageFromColor:[ASDKDesign colorN4Separator]]];
}

- (void)setShouldShowTopSeparator:(BOOL)shouldShowTopSeparator
{
    _shouldShowTopSeparator = shouldShowTopSeparator;
    
    self.customTopSeparatorHeight.constant = _shouldShowTopSeparator ? kSeparatorLineHeight : 0;
}

- (void)setShouldShowBottomSeparator:(BOOL)shouldShowBottomSeparator
{
    _shouldShowBottomSeparator = shouldShowBottomSeparator;
    
    self.customBottomSeparatorHeight.constant = _shouldShowBottomSeparator ? kSeparatorLineHeight : 0;
}

@end
