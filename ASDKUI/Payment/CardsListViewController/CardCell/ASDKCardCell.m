//
//  ASDKCardCell.m
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

#import "ASDKCardCell.h"

@interface ASDKCardCell ()

@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end

@implementation ASDKCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}

+ (instancetype)newCell
{
    ASDKCardCell *newCell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    
    if (newCell)
    {
    }
    
    return newCell;
}

- (void)setCheck:(BOOL)value
{
	CGFloat alpha = value ? 1.0f : 0.0f;
	
	[self.checkmarkImageView setAlpha:alpha];
}

- (void)setCard:(ASDKCard *)card
{
    _card = card;
    
    [self configureCellWithCard:_card];
}

- (void)configureCellWithCard:(ASDKCard *)card
{
    [self.cardNameLabel setText:[card panExtraShort]];
    [self setPaymentSystemLogoImageWithCardType:_card.cardType];
}

- (void)setPaymentSystemLogoImageWithCardType:(ASDKCardType)type
{
    NSString *imageName = nil;
    
    switch (type)
    {
        case ASDKCardTypeVisa:
        {
            imageName = @"psIconVisa";
        }
            break;
        case ASDKCardTypeMastercard:
        {
            imageName = @"psIconMastercard";
        }
            break;
        case ASDKCardTypeMaestro:
        {
            imageName = @"psIconMaestro";
        }
            break;
			
		case ASDKCardTypeMIR:
		{
			imageName = @"psIconMir";
		}
			break;
			
		default:
			imageName = @"psIconMastercard";
			break;
    }
	
    [self.paymentSystemLogoImageView setImage:[UIImage imageNamed:imageName inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
}


@end
