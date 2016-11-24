//
//  NSURLConnectionWithTag.m
//  BirchHillTemp
//
//  Created by Gary Holton on 9/5/11.
//  Copyright 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "NSURLConnectionWithTag.h"


@implementation NSURLConnectionWithTag

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)myTag {
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    
    if (self) {
        self.tag = myTag;
    }
    return self;
}

- (id)initWithURLString:(NSString *)requestString delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)myTag {

    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    if (!(self = [self initWithRequest:request delegate:delegate startImmediately:startImmediately tag:myTag])) return nil;
    
    return self;
}
    


- (NSString *)tag {
    return tag;
}



@end
