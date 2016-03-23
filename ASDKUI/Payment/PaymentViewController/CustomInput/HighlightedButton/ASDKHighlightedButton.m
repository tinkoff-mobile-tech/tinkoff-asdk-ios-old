//
//  ASDKHighlightedButton.m
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

#import "ASDKHighlightedButton.h"

@implementation ASDKHighlightedButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    UIColor *color = highlighted ? [UIColor lightGrayColor] : [UIColor clearColor];
    
    [UIView animateWithDuration:0.2f
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         self.backgroundColor = color;
     }
                     completion:nil];
}


@end
