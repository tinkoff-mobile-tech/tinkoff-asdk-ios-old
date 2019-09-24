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
#import "ASDKLoaderViewController.h"

#define kASDKSubmit3DSAuthorization @"Submit3DSAuthorization"

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

@end

@implementation ASDK3DSViewController

#pragma mark - Getters

#pragma mark - Init

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
    self.webView = [[WKWebView alloc] initWithFrame: CGRectZero configuration: wkWebConfig];
	self.webView.UIDelegate = self;
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
	
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationItem.leftBarButtonItem = [[ASDKBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel3DS)];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.threeDsData.ACSUrl];
	request.timeoutInterval = _acquiringSdk.apiRequestsTimeoutInterval;
    [request setHTTPMethod:@"POST"];
    NSString *dataString = [self stringFromParameters:[self parameters]];

    NSData *postData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:postData];
		
	[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationShowLoader object:nil];
	
    [self.webView loadRequest:request];
}

- (NSString *)termUrl
{
	return [self.acquiringSdk termPath];
}

- (NSDictionary *)parameters
{
    NSString *termUrl = [self termUrl];
    
    return @{kASDKPaReq : self.threeDsData.paReq,
             kASDKMD : self.threeDsData.MD,
             kASDKTermUrl : termUrl};
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
	[webView evaluateJavaScript:@"document.getElementsByName('PaRes')[0].value" completionHandler:^(id _Nullable value, NSError * _Nullable error) {
		if (error == nil)
		{
			NSString *paRes = (NSString *)value;
			if (paRes.length > 0)
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
		}
	}];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    
    if ([urlString rangeOfString:@"cancel.do"].location != NSNotFound)
    {
        [self cancel3DS];
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
	
    if ([webView.request.URL.absoluteString isEqualToString:[self termUrl]])
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
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ASDKNotificationHideLoader object:nil];
    
    [self  closeSelfWithCompletion:^
     {
         if (self.onError)
         {
             self.onError([ASDKAcquringSdkError acquiringErrorWithError:error]);
         }
     }];
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
              if (status == ASDKPaymentStatus_CONFIRMED || status == ASDKPaymentStatus_AUTHORIZED)
              {
                  if (self.onSuccess)
                  {
                      self.onSuccess(self.paymentId);
                  }
              }
              else
              {
                  NSString *details = [NSString stringWithFormat:@"%@",paymentInfo];
                  
                  ASDKAcquringSdkError *stateError = [ASDKAcquringSdkError errorWithMessage:nil
                                                                                    details:details
                                                                                       code:0];
                  
                  if (self.onError)
                  {
                      self.onError(stateError);
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
				NSString *message = @"AddCard state error";
				NSString *details = [NSString stringWithFormat:@"%@", response.message];
				
				ASDKAcquringSdkError *stateError = [ASDKAcquringSdkError errorWithMessage:message details:details code:0];
				
				if (self.onError)
				{
					self.onError(stateError);
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
