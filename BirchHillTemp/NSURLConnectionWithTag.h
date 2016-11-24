//
//  NSURLConnectionWithTag.h
//  BirchHillTemp
//
//  Created by Gary Holton on 9/5/11.
//  Copyright 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURLConnectionWithTag : NSURLConnection {
    
    NSString *tag;
}

@property (nonatomic, strong) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)myTag;

- (id)initWithURLString:(NSString *)requestString delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString *)myTag;

@end