//
//  HTML.m
//  tabbedApp
//
//  Created by Gary Holton on 11/27/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "HTML.h"

@implementation HTML

@synthesize stripped;

-(id) initWithHTML:(NSString *)htmlString;
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<.*?>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) 
    {
        NSLog(@"Error stripping HTML");
        self.stripped = htmlString;
    }
    else
    {
        NSString *strip = [regex stringByReplacingMatchesInString:htmlString
                                                             options:NSRegularExpressionCaseInsensitive
                                                               range:NSMakeRange(0, [htmlString length])
                                                        withTemplate:@""];
        NSString *reStrip = [strip stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        [self setStripped:reStrip];
    }

    // NSLog(@"Before: =%@=\nAfter: =%@=",htmlString, self.stripped);
    return self;
    
}
@end
