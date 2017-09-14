//
//  ASDKFooterCell.m
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
#import "ASDKFooterCell.h"
#import "ASDKDesign.h"

@interface ASDKFooterCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageViewLogos;
@property (weak, nonatomic) UIView *customLogosView;

@end

@implementation ASDKFooterCell

+ (instancetype)cell
{
    ASDKFooterCell *cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"ASDKFooterCell" owner:self options:nil] objectAtIndex:0];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	if (self.customLogosView)
	{
		[self.customLogosView removeFromSuperview];
		self.customLogosView = nil;
	}
	
    [self.contentView setBackgroundColor:[ASDKDesign colorTableViewBackground]];
}

- (void)setCustomSecureLogos:(UIView *)view
{
	[self.imageViewLogos setHidden:(view != nil)];
	
	self.customLogosView = view;
	[self.contentView addSubview:view];

	view.center = self.contentView.center;
}

- (void)layoutSubviews
{
	if (self.customLogosView)
	{
		self.customLogosView.center = self.contentView.center;
	}
	
	[super layoutSubviews];
}

@end
