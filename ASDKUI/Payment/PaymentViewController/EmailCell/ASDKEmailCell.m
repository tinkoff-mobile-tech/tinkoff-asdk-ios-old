//
//  ASDKEmailCell.m
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

#import "ASDKEmailCell.h"
#import "ASDKDesign.h"
#import "ASDKMacroses.h"

@implementation ASDKEmailCell

+ (instancetype)cell
{
    ASDKEmailCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"ASDKEmailCell" owner:self options:nil] objectAtIndex:0];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.emailTextField.textColor = [ASDKDesign colorTextDark];
    self.emailTextField.tintColor = [ASDKDesign colorTextDark];
	
    NSDictionary *placeholderAttributes = @{NSForegroundColorAttributeName:[ASDKDesign colorTextPlaceholder]};
    NSAttributedString *placeholderString = [[NSAttributedString alloc] initWithString:LOC(@"emailCell.placeholder") attributes:placeholderAttributes];
    
    self.emailTextField.attributedPlaceholder = placeholderString;
    
    [self.emailTextField setFont:[UIFont systemFontOfSize:17.0 weight:UIFontWeightLight]];
}

@end
