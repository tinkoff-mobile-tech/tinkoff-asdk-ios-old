//
//  ASDK3DSViewController.m
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

#import "ASDK3DSViewController.h"
#import <ASDKCore/ASDKApiKeys.h>
#import <ASDKCore/ASDKAcquiringSdk.h>
#import <ASDKCore/ASDKUtilsRequest.h>

#import "ASDKLoaderViewController.h"

#import "ASDKNavigationController.h"

#import "ASDKPaymentFormStarter.h"

#import "ASDKBarButtonItem.h"

#import <WebKit/WebKit.h>


typedef NS_ENUM(NSInteger, CheckStateType)
{
	CheckStateType_payment,
	CheckStateType_addCardState
};

@interface ASDK3DSViewController () <WKUIDelegate, WKNavigationDelegate>

@property(nonatomic, strong) ASDKAcquiringSdk *acquiringSdk;

@property (nonatomic) WKWebView *webView;

@property (nonatomic, strong) NSString *paymentId;
@property (nonatomic, strong) NSString *addCardRequestKey;

@property (nonatomic, strong) ASDKThreeDsData *threeDsData;

@property (nonatomic, strong) void (^onSuccess)(NSString *result);
@property (nonatomic, strong) void (^onCancelled)(void);
@property (nonatomic, strong) void (^onError)(ASDKAcquringSdkError *error);

@property (nonatomic, assign) CheckStateType checkStateType;
@property (nonatomic, copy) NSString *termURL;

@end

@implementation ASDK3DSViewController

- (void)dealloc
{
    NSLog(@"DALLOC %@",NSStringFromClass([self class]));
}

- (instancetype)initWithPaymentId:(NSString *)paymentId
                      threeDsData:(ASDKThreeDsData *)data
                     acquiringSdk:(ASDKAcquiringSdk *)acquiringSdk
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
    if (self)
    {
        _paymentId = paymentId;
        _threeDsData = data;
        _acquiringSdk = acquiringSdk;
		_checkStateType = CheckStateType_payment;
    }
    
    return self;
}

- (instancetype)initWithAddCardRequestKey:(NSString *)requestKey
					  threeDsData:(ASDKThreeDsData *)data
					 acquiringSdk:(ASDKAcquiringSdk *)acquiringSdk
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
	if (self)
	{
		_addCardRequestKey = requestKey;
		_threeDsData = data;
		_acquiringSdk = acquiringSdk;
		_checkStateType = CheckStateType_addCardState;
	}
	
	return self;
}

- (void)showFromViewController:(UIViewController *)viewController
                       success:(void (^)(NSString *result))success
                       failure:(void (^)(ASDKAcquringSdkError *statusError))failure
                        cancel:(void (^)(void))cancel
{
    self.onSuccess = success;
    self.onError = failure;
    self.onCancelled = cancel;
    
    ASDKNavigationController *nc = [[ASDKNavigationController  alloc] initWithRootViewController:self];
    [viewController presentViewController:nc animated:YES completion:nil];
}

#pragma mark - ViewController Lifecycle

- (void)setupWebView
{
	WKWebViewConfiguration *wkWebConfig = [WKWebViewConfiguration new];

	[wkWebConfig.preferences setJavaScriptEnabled:YES];
	[wkWebConfig.preferences setJavaScriptCanOpenWindowsAutomatically:YES];
	
    self.webView = [[WKWebView alloc] initWithFrame: CGRectZero configuration: wkWebConfig];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;

	[self.view addSubview: self.webView];

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem: self.webView
                                 attribute: NSLayoutAttributeTop
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.view
                                 attribute: NSLayoutAttributeTop
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem: self.webView
                                 attribute: NSLayoutAttributeBottom
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.view
                                 attribute: NSLayoutAttributeBottom
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem: self.webView
                                 attribute: NSLayoutAttributeLeft
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.view
                                 attribute: NSLayoutAttributeLeft
                                multiplier: 1.0
                                  constant: 0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem: self.webView
                                 attribute: NSLayoutAttributeRight
                                 relatedBy: NSLayoutRelationEqual
                                    toItem: self.view
                                 attribute: NSLayoutAttributeRight
                                multiplier: 1.0
                                  constant: 0];
    
    NSArray *wb_constraints = @[ topConstraint,
								 bottomConstraint,
								 leftConstraint,
								 rightConstraint
								];
    
    [self.view addConstraints: wb_constraints];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupWebView];
  
    if (@available(iOS 13.0, *)) {
        [self.view setBackgroundColor:[UIColor systemBackgroundColor]];
    } else {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    
    self.navigationItem.leftBarButtonItem = [[ASDKBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel3DS)];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: self.threeDsData.acsUrl]];
	request.timeoutInterval = _acquiringSdk.apiRequestsTimeoutInterval;
	[request setAllHTTPHeaderFields:[ASDKUtilsRequest defaultHTTPHeaders]];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod: @"POST"];
	
	if (self.threeDsData.tdsServerTransId != nil && self.threeDsData.acsTransId != nil)
	{
		self.termURL = [NSString stringWithFormat:@"%@%@", [self.acquiringSdk domainPath_v2], kASDKSubmit3DSAuthorization];
		NSString *paramsString = [NSString stringWithFormat:@"{\"threeDSServerTransID\":\"%@\",\"acsTransID\":\"%@\",\"messageVersion\":\"%@\",\"challengeWindowSize\":\"05\",\"messageType\":\"CReq\"}",
								  self.threeDsData.tdsServerTransId, self.threeDsData.acsTransId, self.threeDsData.threeDSVersion];
		
		NSData *plainData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
		NSString *postString = [NSString stringWithFormat:@"%@", [plainData base64EncodedStringWithOptions:0]];
		NSData *postData = [[NSString stringWithFormat:@"creq=%@", postString] dataUsingEncoding: NSUTF8StringEncoding];
		
		[request setHTTPBody: postData];
	}
	else if (self.threeDsData.paReq != nil && self.threeDsData.MD != nil)
	{
		self.termURL = [NSString stringWithFormat:@"%@%@", [self.acquiringSdk domainPath], kASDKSubmit3DSAuthorization];
		
		NSMutableDictionary *params = [NSMutableDictionary dictionary];
		[params setValue:self.threeDsData.paReq forKey:kASDKPaReq];
		[params setValue:self.threeDsData.MD forKey:kASDKMD];
		[params setValue:self.termURL forKey:kASDKTermUrl];
		
		NSString *dataString = [self stringFromParameters:params];
		
		NSData *postData = [dataString dataUsingEncoding: NSUTF8StringEncoding];
		[request setHTTPBody: postData];
	}
		
	[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
	[self.webView loadRequest:request];
}

- (NSString *)stringFromParameters:(NSDictionary *)parameters
{
    NSString *dataString = @"";
    
    NSCharacterSet *URLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@" \"#%/:<>?@[\\]^`{|}+="] invertedSet];
    
    for (NSString *key in parameters.allKeys)
    {
        id value = parameters[key];
        
        if ([value isKindOfClass:[NSString class]])
        {
            value = [(NSString *)value stringByAddingPercentEncodingWithAllowedCharacters:URLCombinedCharacterSet];
        }
        
        NSString *singleString = [NSString stringWithFormat:@"%@=%@",key,value];
        
        dataString = [NSString stringWithFormat:@"%@%@%@",dataString,dataString.length > 0 ? @"&" : @"", singleString];
    }
    
    return dataString;
}


#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
	if (self.webView == webView)
	{
		[self.webView evaluateJavaScript:@"document.baseURI" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
			if (error == nil)
			{
				NSString *termUrl = (NSString *)value;
				if ([termUrl rangeOfString:@"cancel.do"].location != NSNotFound)
				{
					[self cancel3DS];
				}
				else if ([termUrl rangeOfString:self.termURL].location != NSNotFound)
				{
					[self.webView evaluateJavaScript:@"document.getElementsByTagName('pre')[0].innerHTML" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
						NSString *responce = (NSString *)value;
						if (responce != nil)
						{
							NSData *data = [responce dataUsingEncoding:NSUTF8StringEncoding];
							NSError *jsonError;
							NSMutableDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
																								options:kNilOptions
																								  error:&jsonError];
							
							ASDKAcquiringResponse *result = [[ASDKAcquiringResponse alloc] initWithDictionary: responseJSON];
							
							if (result.success == true && [result.errorCode integerValue] == 0)
							{
								switch (self.checkStateType) {
									case CheckStateType_payment:
										[self checkPaymentState];
										break;

									default:
										[self checkAddCardState];
										break;
								}
							}
							else
							{
								[self closeSelfWithCompletion:^{
									if (self.onError)
									{
										NSString *errorMessage = result.message;
										NSString *errorDetails = result.details == nil ? @"3ds checking error" : result.details;
										NSInteger errorCode = result.errorCode == nil ? 0 : [result.errorCode integerValue];
										
										ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage: errorMessage
																									 details: errorDetails
																										code: errorCode];
										self.onError(error);
									}
								}];
							}
						}
					}];
				}
			}
		}];

		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
	}
}

- (void)cancel3DS
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
    
    [self closeSelfWithCompletion:^
     {
         if (self.onCancelled)
         {
             self.onCancelled();
         }
     }];
}

- (void)closeSelfWithCompletion:(void (^)(void))completion
{
    [self dismissViewControllerAnimated:YES completion:completion];
}

- (void)checkPaymentState
{
    self.webView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
    
    [self.acquiringSdk getStateWithPaymentId:self.paymentId success:^(ASDKPaymentInfo *paymentInfo, ASDKPaymentStatus status) {
         [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
         
         [self closeSelfWithCompletion:^{
              if (status == ASDKPaymentStatus_CONFIRMED || status == ASDKPaymentStatus_AUTHORIZED || status == ASDKPaymentStatus_3DS_CHECKED)
              {
                  if (self.onSuccess)
                  {
                      self.onSuccess(self.paymentId);
                  }
              }
              else
              {
				  ASDKAcquiringResponse *result = [[ASDKAcquiringResponse alloc] initWithDictionary: paymentInfo.dictionary];
				  NSString *errorMessage = result.message;
				  NSString *errorDetails = result.details == nil ? [NSString stringWithFormat: @"%@", paymentInfo] : result.details;
				  NSInteger errorCode = result.errorCode == nil ? 0 : [result.errorCode integerValue];
				  
				  ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage: errorMessage
																			   details: errorDetails
																				  code: errorCode];
                  
                  if (self.onError)
                  {
                      self.onError(error);
                  }
              }
          }];
     }
                                    failure:^(ASDKAcquringSdkError *error)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
         
         [self closeSelfWithCompletion:^{
              if (self.onError)
              {
                  self.onError(error);
              }
          }];
     }];
}

- (void)checkAddCardState
{
	self.webView.hidden = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];

	[self.acquiringSdk getStateAttachCardWithRequestKey:self.addCardRequestKey success:^(ASDKResponseGetAddCardState *response) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
		[self closeSelfWithCompletion:^{
			if (response.status == ASDKPaymentStatus_COMPLETED)
			{
				if (self.onSuccess)
				{
					self.onSuccess([response cardId]);
				}
			}
			else
			{
				NSString *errorMessage = response.message;
				NSString *errorDetails = response.details == nil ?  @"AddCard state error" : response.details;
				NSInteger errorCode = response.errorCode == nil ? 0 : [response.errorCode integerValue];
				
				ASDKAcquringSdkError *error = [ASDKAcquringSdkError errorWithMessage: errorMessage
																			 details: errorDetails
																				code: errorCode];
				
				if (self.onError)
				{
					self.onError(error);
				}
			}
		}];
	} failure:^(ASDKAcquringSdkError *error) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
		
		[self closeSelfWithCompletion:^{
			 if (self.onError)
			 {
				 self.onError(error);
			 }
		 }];
	}];
}

@end
