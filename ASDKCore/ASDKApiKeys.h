//
//  ASDKApiKeys.h
//  ASDKCore
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

#ifndef ASDKApiKeys_h
#define ASDKApiKeys_h

#pragma mark - API Path

////v1
#define kASDKTestDomainName                 @"https://rest-api-test.tcsbank.ru/rest/"
#define kASDKDomainName                     @"https://securepay.tinkoff.ru/rest/"

//v2
#define kASDKTestDomainName_v2                 @"https://rest-api-test.tcsbank.ru/v2/"
#define kASDKDomainName_v2                     @"https://securepay.tinkoff.ru/v2/"

#define kASDKAPIPathInit                    @"Init"
#define kASDKAPIPathFinishAuthorize         @"FinishAuthorize"
#define kASDKAPIPathCharge                  @"Charge"
#define kASDKAPIPathCancel                  @"Cancel"
#define kASDKAPIPathGetState                @"GetState"
#define kASDKAPIPathGetCardList             @"GetCardList"
#define kASDKAPIPathRemoveCard              @"RemoveCard"

#pragma mark - Response fields

#define kASDKSuccess                        @"Success"
#define kASDKErrorCode                      @"ErrorCode"
#define kASDKTerminalKey                    @"TerminalKey"
#define kASDKToken                          @"Token"
#define kASDKStatus                         @"Status"
#define kASDKPaymentId                      @"PaymentId"
#define kASDKOrderId                        @"OrderId"
#define kASDKAmount                         @"Amount"
#define kASDKPaymentURL                     @"PaymentURL"
#define kASDKCardId                         @"CardId"
#define kASDKPan                            @"Pan"
#define kASDKPAN                            @"PAN"
#define kASDKExpDate                        @"ExpDate"
#define kASDKCVV                            @"CVV"
#define kASDKRebillId                       @"RebillId"
#define kASDKCustomerKey                    @"CustomerKey"
#define kASDKDetails                        @"Details"
#define kASDKMessage                        @"Message"
#define kASDKDescription                    @"Description"
#define kASDKDATA                           @"DATA"
#define kASDKReceipt						@"Receipt"
#define kASDKShops							@"Shops"
#define kASDKReceipts						@"Receipts"
#define kASDKPayForm                        @"PayForm"
#define kASDKPayType                        @"PayType"
#define kASDKRecurrent                      @"Recurrent"
#define kASDKPassword                       @"Password"
#define kASDKSendEmail                      @"SendEmail"
#define kASDKCardData                       @"CardData"
#define kASDKThreeDsData                    @""
#define kASDKPaymentInfo                    @""
#define kASDKAcquringResponse               @"acquringResponse"
#define kASDKASCUrl                         @"ACSUrl"
#define kASDKMD                             @"MD"
#define kASDKPaReq                          @"PaReq"
#define kASDKCard                           @""
#define kASDKTermUrl                        @"TermUrl"
#define kASDKInfoEmail                      @"InfoEmail"

#pragma mark - API Error

#define kASDKErrorMessage                   @"errorMessage"
#define kASDKErrorDetails                   @"errorDetails"

#pragma mark - PaymentStatus

#define kASDKPaymentStatusNew               @"NEW"
#define kASDKPaymentStatusCancelled         @"CANCELLED"
#define kASDKPaymentStatusPreauthorizing    @"PREAUTHORIZING"
#define kASDKPaymentStatusFormshowed        @"FORMSHOWED"
#define kASDKPaymentStatusAuthorizing       @"AUTHORIZING"
#define kASDKPaymentStatus3DSChecking       @"3DS_CHECKING"
#define kASDKPaymentStatus3DSChecked        @"3DS_CHECKED"
#define kASDKPaymentStatusAuthorized        @"AUTHORIZED"
#define kASDKPaymentStatusReversing         @"REVERSING"
#define kASDKPaymentStatusReversed          @"REVERSED"
#define kASDKPaymentStatusConfirming        @"CONFIRMING"
#define kASDKPaymentStatusConfirmed         @"CONFIRMED"
#define kASDKPaymentStatusRefunding         @"REFUNDING"
#define kASDKPaymentStatusRefunded          @"REFUNDED"
#define kASDKPaymentStatusRejected          @"REJECTED"
#define kASDKPaymentStatusUnknown           @"UNKNOWN"
#define kASDKPaymentStatusCOMPLETED         @"COMPLETED"

#pragma mark - CardStatus

#define kASDKCardStatusActive               @"A"
#define kASDKCardStatusInactive             @"I"

#endif /* ASDKApiKeys_h */
