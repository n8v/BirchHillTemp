//
//  CapturesFromRegex.m
//  tabbedApp
//
//  Created by Gary Holton on 11/27/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "CapturesFromRegex.h"

@implementation CapturesFromRegex
@synthesize captures;

-(id) initWithRegex:(NSString *)regexString fromString:(NSString *)fromString
{    
    NSMutableArray *capturesArray = [[[NSMutableArray alloc] initWithObjects: nil] autorelease] ;
    NSError *error = NULL;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexString 
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error ];
    if (!error) {
        NSArray *resultArray = [[NSArray alloc] initWithArray:[regex matchesInString:fromString
                                                                             options:0
                                                                               range:NSMakeRange(0, [fromString length])] ] ;
        if ([resultArray count] > 0) {
            // mostly just interested in first match
            NSTextCheckingResult *result = [resultArray objectAtIndex:0]; 
            // NSLog(@"%@",result);
            // NSLog(@"Number of ranges: %d", [result numberOfRanges]);
            for (int i=1; i< [result numberOfRanges]; i++) {
                //           NSLog(@"Range %d, %@",i,[result rangeAtIndex:i]);
                NSString *capture = [fromString substringWithRange:[result rangeAtIndex:i]];
                
                // NSLog(@"Captures array: %@",capturesArray);
                [capturesArray addObject:capture];
            }
            
        }
        [resultArray release], resultArray = nil;
    }
    [regex release], regex = nil;
    self.captures = capturesArray;
    return self;
}

-(NSMutableArray *)getCaptures
{
    return self.captures;
}

-(void) dealloc
{
    [captures release]
    captures = nil;
    [super dealloc]
    
}

@end
