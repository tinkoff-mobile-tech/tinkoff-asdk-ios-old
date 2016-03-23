//
//  ASDKPaymentFormSummCell.m
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

#import "ASDKPaymentFormSummCell.h"
#import "ASDKDesign.h"
#import "ASDKMacroses.h"

@implementation ASDKPaymentFormSummCell

+ (instancetype)cell
{
    ASDKPaymentFormSummCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"ASDKPaymentFormSummCell" owner:self options:nil] objectAtIndex:0];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.summLabel.textColor = [ASDKDesign colorTextDark];
    self.summTitleLabel.textColor = [ASDKDesign colorTextLight];
    self.summTitleLabel.text = LOC(@"PaymentForm.summCellTitle");
}

@end
