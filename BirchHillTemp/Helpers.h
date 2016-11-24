//
//  Helpers.h
//  BirchHillTemp
//
//  Created by Gary Holton on 16/01/2013.
//
//

#import <Foundation/Foundation.h>

@interface Helpers : NSObject

NSString *timeSinceUpdate(NSDate *update);

NSArray *getCapturesFromRegex(NSString *regexString, NSString *fromString);

NSString *cleanText(NSString *someText);

NSString *getFirstCaptureFromRegex(NSString *regexString, NSString *fromString);

NSString *stripHTML(NSString *html);

@end
