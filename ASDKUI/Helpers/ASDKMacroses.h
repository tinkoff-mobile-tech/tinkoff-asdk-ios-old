//
//  ASDKMacroses.h
//  ASDK
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



#pragma mark -
#pragma mark Logging & Assert

#ifdef DEBUG
	#define DEBUG_LOG
#endif

#ifdef ALog
#	undef ALog
#endif
#ifdef DLog
#	undef DLog
#endif

#ifdef DEBUG_LOG

#define DLog( s, ... )								NSLog( @"%@%s:(%d)> %@", [[self class] description], __FUNCTION__ , __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define ErrLog( s, ... )							NSLog( @"%@%s:(%d)> \n\n💥💥💥\nError: %@\n💥💥💥\n\n", [[self class] description], __FUNCTION__ , __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define ALog( s, ... )								\
    NSString * const __ALogErrorString__ = [NSString stringWithFormat:(s), ##__VA_ARGS__];\
    UIAlertView * const __ALogErrorAlert__ = [[UIAlertView alloc]initWithTitle:@"Error!" message:__ALogErrorString__ delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];\
    [__ALogErrorAlert__ show];\
													DLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__]);
#else

#define ALog( s, ... )
#define DLog( s, ... )
#define ErrLog( s, ... )

#endif



///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Localization

//#define LOC(key)									[[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:@"ASDKLocalizable"]

///////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark SINGLETON_GCD

#define SINGLETON_GCD(classname)\
+ (id)sharedInstance\
{\
static dispatch_once_t pred = 0;\
__strong static id _sharedObject##classname = nil;\
dispatch_once(&pred,\
^{\
_sharedObject##classname = [[self alloc] init];\
});\
return _sharedObject##classname;\
}\


///////////////////////////////////////////////////////////////////

