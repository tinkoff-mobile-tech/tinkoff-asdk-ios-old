//
//  ASDKCardInputViewController.m
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

#import "ASDKCardInputViewController.h"
#import "ASDKNumberCell.h"
#import "ASDKDeleteCell.h"
#import <AudioToolbox/AudioToolbox.h>

#define kSeparatorLineHeight		1.0f / [[UIScreen mainScreen] scale]
#define kRowsNumber 4
#define kColumnsNumber 3

@interface ASDKCardInputViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *keyboardCollectionView;

@property (nonatomic) CGSize keyboardSize;

@property (weak, nonatomic) NSTimer *timer;

@end

@implementation ASDKCardInputViewController

#pragma mark - Init

- (instancetype)initWithCustomInputKeyboardSize:(CGSize)size
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
    if (self)
    {
        _keyboardSize = size;
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
    }
    
    return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINib *numberCellNib = [UINib nibWithNibName:NSStringFromClass([ASDKNumberCell class]) bundle:[NSBundle bundleForClass:[ASDKNumberCell class]]];
    [self.keyboardCollectionView registerNib:numberCellNib forCellWithReuseIdentifier:NSStringFromClass([ASDKNumberCell class])];
    
    UINib *deleteCellNib = [UINib nibWithNibName:NSStringFromClass([ASDKDeleteCell class]) bundle:[NSBundle bundleForClass:[ASDKDeleteCell class]]];
    [self.keyboardCollectionView registerNib:deleteCellNib forCellWithReuseIdentifier:NSStringFromClass([ASDKDeleteCell class])];
}


#pragma mark - Collection view Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    NSString *reuseIdentifier = nil;
    
    switch (indexPath.row)
    {
        case 11:
        {
            reuseIdentifier = NSStringFromClass([ASDKDeleteCell class]);
        }
            break;
            
        default:
        {
            reuseIdentifier = NSStringFromClass([ASDKNumberCell class]);
        }
            break;
    }
    
    cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 9:
        {
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setUserInteractionEnabled:NO];
        }
            break;
        case 10:
        {
            UIButton *numberButton = [(ASDKNumberCell *)cell numberButton];
            [numberButton setTitle:@"0" forState:UIControlStateNormal];
            [numberButton addTarget:self action:@selector(keyboardInputButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 11:
        {
            UIButton *deleteButton = [(ASDKDeleteCell *)cell deleteButton];
            [cell setBackgroundColor:[UIColor clearColor]];
            [deleteButton addTarget:self action:@selector(keyboardInputDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [[(ASDKDeleteCell *)cell deleteButtonLongPress] addTarget:self action:@selector(continousDelete:)];
        }
            break;
            
        default:
        {
            UIButton *numberButton = [(ASDKNumberCell *)cell numberButton];
            [numberButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)indexPath.row + 1] forState:UIControlStateNormal];
            [numberButton addTarget:self action:@selector(keyboardInputButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
    }
}


#pragma mark - Collection view flow layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = collectionView.frame.size.height / kRowsNumber;//_keyboardSize.height / kRowsNumber;
	CGFloat width = collectionView.frame.size.width / kColumnsNumber;//_keyboardSize.width / kColumnsNumber;

    return CGSizeMake(width, height);
}

#pragma mark - Actions

- (void)keyboardInputButtonPressed:(UIButton *)sender
{
    AudioServicesPlaySystemSound(0x450);
    
    id <ASDKCustomKeyboardInputDelegate> delegate = self.customKeyboardInputDelegate;
    if (delegate && [delegate respondsToSelector:@selector(didEnterNumber:)])
    {
        [delegate didEnterNumber:@([sender.titleLabel.text integerValue])];
    }
}

- (void)keyboardInputDeleteButtonPressed:(UIButton *)sender
{
    AudioServicesPlaySystemSound(0x450);
    
    id <ASDKCustomKeyboardInputDelegate> delegate = self.customKeyboardInputDelegate;
    if (delegate && [delegate respondsToSelector:@selector(didPressOnDeleteButton)])
    {
        [delegate didPressOnDeleteButton];
    }
}

- (void)continousDelete:(UILongPressGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(keyboardInputDeleteButtonPressed:) userInfo:nil repeats:YES];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            [_timer invalidate];
        }
            break;
        default:
            break;
    }
}

@end
