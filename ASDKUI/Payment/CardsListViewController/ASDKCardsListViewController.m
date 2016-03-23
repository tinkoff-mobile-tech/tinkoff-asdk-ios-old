//
//  ASDKCardsListViewController.m
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


#import "ASDKCardsListViewController.h"
#import "ASDKCardCell.h"
#import "ASDKAddNewCardCell.h"
#import "ASDKMacroses.h"
#import "ASDKDesign.h"
#import "ASDKBarButtonItem.h"
#import "ASDKCardsListDataController.h"
#import "ASDKLoaderViewController.h"
#import "ASDKMacroses.h"

typedef enum
{
    ASDKCardsListSectionCard,
    ASDKCardsListSectionAddNewCard
} ASDKCardsListSection;

@interface ASDKCardsListViewController ()

@property (nonatomic, strong) ASDKAddNewCardCell *addNewCardCell;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic) BOOL didRemoveCards;

@end

@implementation ASDKCardsListViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self)
    {
        _cards = [ASDKCardsListDataController instance].externalCards;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = LOC(@"Title.CardsList");
    
    [self.tableView setBackgroundColor:[ASDKDesign colorTableViewBackground]];
    
    ASDKBarButtonItem *cancelButton = [[ASDKBarButtonItem alloc] initWithTitle:LOC(@"Common.Cancel")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (IBAction)cancelAction:(id)sender
{
    [self closeSelfWithCompletion:nil];
}

- (ASDKAddNewCardCell *)addNewCardCell
{
    if (!_addNewCardCell)
    {
        _addNewCardCell = [ASDKAddNewCardCell newCell];
        _addNewCardCell.shouldShowTopSeparator = YES;
        _addNewCardCell.shouldShowBottomSeparator = YES;
        _addNewCardCell.addCardTitleLabel.text = LOC(@"CardsList.AddNewCard");
    }
    
    return _addNewCardCell;
}


#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section)
    {
        case ASDKCardsListSectionCard:
        {
            numberOfRows = _cards.count;
        }
            break;
        case ASDKCardsListSectionAddNewCard:
        {
            numberOfRows = 1;
        }
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section)
    {
        case ASDKCardsListSectionCard:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ASDKCardCell class])];
            if (!cell)
            {
                cell = [ASDKCardCell newCell];
            }
            
            [(ASDKCardCell *)cell setCard:_cards[indexPath.row]];
            
            if ([_cards[indexPath.row] isEqual:_selectedCard])
            {
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            if (indexPath.row == 0)
            {
                ((ASDKCardCell *)cell).shouldShowTopSeparator = YES;
            }
            else
            {
                ((ASDKCardCell *)cell).shouldShowBottomSeparator = YES;
            }
        }
            break;
        case ASDKCardsListSectionAddNewCard:
        {
            cell = [self addNewCardCell];
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        ASDKCard *card = _cards[indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
        
        __weak typeof (self) weakSelf = self;
        [[ASDKCardsListDataController instance] removeCardWithCardId:@([card.cardId integerValue])
                                                        successBlock:^
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
             
             [weakSelf setCards:[ASDKCardsListDataController instance].externalCards];
             
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             [tableView reloadData];
             
             _didRemoveCards = YES;
         }
                                                          errorBlock:^(ASDKAcquringSdkError *error)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
         }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    ASDKCard *selectedCard = nil;
    
    if (indexPath.section == ASDKCardsListSectionCard)
    {
        selectedCard = _cards[indexPath.row];
    }
    
    id<ASDKCardsListDelegate> cardsListDelegate = self.cardsListDelegate;
    
    if (cardsListDelegate && [cardsListDelegate respondsToSelector:@selector(didSelectCard:)])
    {
        [cardsListDelegate didSelectCard:selectedCard];
    }
    
    [self closeSelfWithCompletion:nil];
}

- (void)closeSelfWithCompletion: (void (^)(void))completion
{
    if (_didRemoveCards)
    {
        id<ASDKCardsListDelegate> delegate = self.cardsListDelegate;
        
        if (delegate && [delegate respondsToSelector:@selector(cardsListDidCancel)])
        {
            [delegate cardsListDidCancel];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:completion];
}


@end
