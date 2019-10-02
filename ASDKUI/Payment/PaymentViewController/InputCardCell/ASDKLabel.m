//
//  ASDKLabel.m
//  ASDKLabel
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

#import "ASDKLabel.h"

#define kGradientWidth 18.0f

@implementation ASDKLabel

- (instancetype)init
{
    if (self = [super init])
    {
        [self enableGradientTruncation];
    }
    
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[self enableGradientTruncation];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
		[self enableGradientTruncation];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self enableGradientTruncation];
	}

	return self;
}

- (void)enableGradientTruncation
{
	[self setAutoresizesSubviews:YES];
	[self setLineBreakMode:NSLineBreakByClipping];
	_gradientLayer = [CAGradientLayer layer];
	_gradientLayer.frame = self.bounds;
	_gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], nil];
    CGFloat startX = kGradientWidth/self.frame.size.width;
	_gradientLayer.startPoint = CGPointMake(1.0f - startX, 0.0f);
	_gradientLayer.endPoint = CGPointMake(0.99f, 0.0f);
}

- (void)setupLayerTruncation
{
    CGFloat systemVersion = (CGFloat)[[[UIDevice currentDevice] systemVersion] floatValue];
	if (systemVersion == 8)
	{
		[self setLineBreakMode:NSLineBreakByTruncatingTail];
		[self.layer setMask:nil];
		return;
	}
	
	if ([self.text length] <= 0)
        return;
	
	[self.layer setMask:nil];

    if (attributedTextSize.width > self.bounds.size.width)
    {
        if (self.numberOfLines == 1)
        {
            [self setupGradientLayer];
        }
        else
        {
            CGSize rect = [self sizeForLabelWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, 1000) inputString:self.text];
			
            if (rect.height > ceil(self.frame.size.height))
            {
                [self setupGradientLayer];
                
                if (_layerWithoutGradient == nil)
                {
                    _layerWithoutGradient = [CALayer layer];
                    if (@available(iOS 13.0, *)) {
                        _layerWithoutGradient.backgroundColor = [UIColor labelColor].CGColor;
                    } else {
                        _layerWithoutGradient.backgroundColor = [UIColor blackColor].CGColor;
                    }
                    _layerWithoutGradient.opacity = 1.0;
                }
                
                CGRect layerWithoutGradientFrame = self.bounds;
                layerWithoutGradientFrame.size.height -= self.font.lineHeight;
                [_layerWithoutGradient setFrame:layerWithoutGradientFrame];
                [_gradientLayer addSublayer:_layerWithoutGradient];
            }
			else
			{
				if (_layerWithoutGradient)
				{
					[_layerWithoutGradient removeFromSuperlayer];
					_layerWithoutGradient = nil;
				}
			}
        }
    }

}

- (void)setupGradientLayer
{
    [_gradientLayer setFrame:self.bounds];
    CGFloat startX = kGradientWidth/_gradientLayer.frame.size.width;
    _gradientLayer.startPoint = CGPointMake(1.0f - startX, 0.0f);
    _gradientLayer.endPoint = CGPointMake(0.99f, 0.0f);
    [self.layer setMask:_gradientLayer];

	if (_layerWithoutGradient)
	{
		[_layerWithoutGradient removeFromSuperlayer];
		_layerWithoutGradient = nil;
	}
}

- (void)setText:(NSString *)text
{
	[super setText:text];
	
	attributedTextSize = [self.attributedText size];
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
	[super setAttributedText:attributedText];

	attributedTextSize = [self.attributedText size];
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)setFont:(UIFont *)font
{
	[super setFont:font];
	
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	[self setupLayerTruncation];
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constraintSize inputString:(NSString *)inputString
{
    CGRect rect = [inputString boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:NULL];
    
    return rect.size;
}

- (CGSize)sizeForLabelWithFont:(UIFont *)font constrainedToSize:(CGSize)constraintSize inputString:(NSString *)inputString
{
    CGSize size = [inputString boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:NULL].size;
    
    size.width = (CGFloat)ceil(size.width);
    size.height = (CGFloat)ceil(size.height);
    
    return size;
}

@end
