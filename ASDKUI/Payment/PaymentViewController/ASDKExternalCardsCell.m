//
//  ASDKExternalCardsCell.m
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

#import "ASDKExternalCardsCell.h"
#import "ASDKDesign.h"
#import "ASDKMacroses.h"

@implementation ASDKExternalCardsCell

+ (instancetype)cell
{
    ASDKExternalCardsCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"ASDKExternalCardsCell" owner:self options:nil] objectAtIndex:0];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.textColor = [ASDKDesign colorTextDark];
    self.changeCardButton.titleLabel.textColor = [ASDKDesign colorMainBlue];
	[self.changeCardButton setTitle:LOC(@"PaymentForm.changeCard") forState:UIControlStateNormal];
	
    self.titleLabel.text = LOC(@"externalCardsCell.newCard");
}

@end
