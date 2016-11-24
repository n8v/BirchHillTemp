//
//  HTML.h
//  tabbedApp
//
//  Created by Gary Holton on 11/27/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTML : NSObject
{
    NSString *stripped;
}

@property (nonatomic, assign) NSString *stripped;
  
-(id) initWithHTML:(NSString *)htmlString;

@end
