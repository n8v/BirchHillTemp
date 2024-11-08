//
//  HTTPFetcher.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 2011/05/20.
//  Copyright 2011 Matt Gallagher. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

@interface HTTPFetcher : NSObject
#if TARGET_OS_IPHONE		
	<UITextFieldDelegate>
#endif
{
	id receiver;
	SEL action;

	NSURLConnection *connection;
	NSMutableData *data;
	NSURLAuthenticationChallenge *challenge;

	NSURLRequest *urlRequest;
	NSInteger failureCode;
	BOOL showAlerts;
	BOOL showAuthentication;
	NSDictionary *responseHeaderFields;
	void *context;
    
    NSString *tag;
	
#if TARGET_OS_IPHONE		
	UITextField *usernameField;
	UITextField *passwordField;
	UIAlertView *passwordAlert;
#endif
}

@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSURLRequest *urlRequest;
@property (nonatomic, readonly) NSDictionary *responseHeaderFields;
@property (nonatomic, readonly) NSInteger failureCode;
@property (nonatomic, assign) BOOL showAlerts;
@property (nonatomic, assign) BOOL showAuthentication;
@property (nonatomic, assign) void *context;

@property (nonatomic, strong) NSString *tag;

- (id)initWithURLRequest:(NSURLRequest *)aURLRequest
                receiver:(id)aReceiver
                  action:(SEL)receiverAction;

- (id)initWithURLRequest:(NSURLRequest *)aURLRequest
                receiver:(id)aReceiver
                  action:(SEL)receiverAction
                      tag:(NSString *)myTag;

- (id)initWithURLString:(NSString *)aURLString
               receiver:(id)aReceiver
                 action:(SEL)receiverAction;

- (id)initWithURLString:(NSString *)aURLString
                receiver:(id)aReceiver
                action:(SEL)receiverAction
                    tag:(NSString *)myTag;


- (id)initWithURLString:(NSString *)aURLString
                timeout:(NSTimeInterval)aTimeoutInterval
            cachePolicy:(NSURLRequestCachePolicy)aCachePolicy
               receiver:(id)aReceiver
                 action:(SEL)receiverAction;

- (void)start;

- (void)cancel;

- (void)close;

@end
