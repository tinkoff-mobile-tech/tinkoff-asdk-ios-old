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
#import "ASDKLocalized.h"

typedef enum
{
    ASDKCardsListSectionCard,
    ASDKCardsListSectionAddNewCard
} ASDKCardsListSection;

@interface ASDKCardsListViewController ()

typedef void(^onAddCallbackT)(void);

@property (nonatomic, strong) ASDKAddNewCardCell *addNewCardCell;
@property (nonatomic, strong) NSArray *cards;
@property (nonatomic) BOOL didRemoveCards;
@property (nonatomic) BOOL editCardList;
@property (nonatomic) int numberOfRows;
@property (nonatomic) onAddCallbackT onAdd;
@property (nonatomic) ASDKBarButtonItem *editButton;

@end

@implementation ASDKCardsListViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    _editCardList = false;
    _numberOfRows = 2;
    
    if (self)
    {
        _cards = [ASDKCardsListDataController instance].externalCards;
    }
    
    return self;
}

- (instancetype)initForEditing:(void (^)(void))onAdd
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    _editCardList = true;
    _numberOfRows = 2;
    _onAdd = onAdd;
    
    if (self)
    {
        _cards = [ASDKCardsListDataController instance].externalCards;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *backBtnLabel = LOC(@"acq_btn_cancel");
    
    if (_editCardList) {
        self.title = LOC(@"acq_title_card_list_edit");
        backBtnLabel = LOC(@"acq_btn_card_list_edit_done");
        
        _editButton = [[ASDKBarButtonItem alloc] initWithTitle:LOC(@"acq_btn_card_list_mode")
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(editAction:)];
        
        _editButton.tintColor = self.navigationController.navigationBar.tintColor;
        [self.navigationItem setRightBarButtonItem:_editButton];
    }
    
    [self.tableView setBackgroundColor:[ASDKDesign colorTableViewBackground]];
    
    ASDKBarButtonItem *cancelButton = [[ASDKBarButtonItem alloc] initWithTitle:backBtnLabel
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelAction:)];
	
	cancelButton.tintColor = self.navigationController.navigationBar.tintColor;
	
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (IBAction)editAction:(id)sender
{
    if (_cards.count == 0)
        return;
    
    [self setEditingNew:!self.isEditing];
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
        _addNewCardCell.selectionStyle = UITableViewCellSelectionStyleNone;
        _addNewCardCell.addCardTitleLabel.text = LOC(@"acq_enter_new_card_label");
    }
    
    return _addNewCardCell;
}


#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _numberOfRows;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section)
    {
		case ASDKCardsListSectionCard:
		{
			id<ASDKCardsListDelegate> cardsListDelegate = self.cardsListDelegate;

			if (cardsListDelegate && [cardsListDelegate respondsToSelector:@selector(filterCardList:)])
			{
				_cards = [cardsListDelegate filterCardList:_cards];
			}

            numberOfRows = _cards.count;
		}
            break;
        case ASDKCardsListSectionAddNewCard:
            numberOfRows = 1;
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
			[(ASDKCardCell *)cell setCheck:[_cards[indexPath.row] isEqual:_selectedCard]];

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
			
		default:
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellDefault"];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL result = NO;
	
	switch (indexPath.section)
	{
  		case ASDKCardsListSectionCard:
			result = YES;
		break;
		
		case ASDKCardsListSectionAddNewCard:
  		default:
			result = NO;
		break;
	}
	
	return result;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ASDKCardsListSectionCard && editingStyle == UITableViewCellEditingStyleDelete)
    {
        ASDKCard *card = _cards[indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
        
        __weak typeof (self) weakSelf = self;
        [[ASDKCardsListDataController instance] removeCardWithCardId:@([card.cardId integerValue])
                                                        successBlock:^
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];

             [weakSelf setCards:[ASDKCardsListDataController instance].externalCards];
             if(!_editCardList){
                 [weakSelf setSelectedCard:[[ASDKCardsListDataController instance].externalCards firstObject]];
             }
             
             if (_cards.count == 0){
                 [weakSelf setEditingNew:false];
             }
			 
			 [tableView beginUpdates];
             	[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			 	[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
			 [tableView endUpdates];

			id<ASDKCardsListDelegate> cardsListDelegate = self.cardsListDelegate;
			if (cardsListDelegate && [cardsListDelegate respondsToSelector:@selector(cardListDidChanged)])
			{
				[cardsListDelegate cardListDidChanged];
			}
			 
			self->_didRemoveCards = YES;
         }
                                                          errorBlock:^(ASDKAcquringSdkError *error)
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
         }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    printf("Click\n");
    if ( self.isEditing )
        return;
        
    ASDKCard *selectedCard = nil;
    
    id<ASDKCardsListDelegate> cardsListDelegate = self.cardsListDelegate;
    
    if (_editCardList){
        if (indexPath.section == ASDKCardsListSectionAddNewCard)
        {
            printf("Card Add requested, check delegate!");
            
            [self closeSelfWithCompletion:_onAdd];
            return;
        }
        return;
    }
	
    if (indexPath.section == ASDKCardsListSectionCard)
    {
        selectedCard = _cards[indexPath.row];
    }
    
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

- (void)setEditingNew: (BOOL)editing// animated:(BOOL)animated
{
//printf("setting editing: %i\n", editing);
    if(editing){
        _editButton.title = LOC(@"acq_btn_card_list_edit_mode");
    } else {
        _editButton.title = LOC(@"acq_btn_card_list_mode");
    }
    
    [self setEditing:editing animated:true];
}

@end
