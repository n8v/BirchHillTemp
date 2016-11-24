//
//  CapturesFromRegex.h
//  tabbedApp
//
//  Created by Gary Holton on 11/27/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CapturesFromRegex : NSObject
{
    NSMutableArray *captures;
}

@property (nonatomic, assign) NSMutableArray *captures;

-(id) initWithRegex:(NSString *)regexString fromString:(NSString *)fromString;
-(NSMutableArray *)getCaptures;

@end
