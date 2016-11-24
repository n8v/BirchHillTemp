//
//  Settings.h
//  BirchHillTemp
//
//  Created by Gary Holton on 12/30/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject
{
    NSString *prefUnits;
    NSString *prefRefreshInterval;
    BOOL prefUse24hour;
    
    NSMutableDictionary *prefTitles;
    NSMutableDictionary *prefValues;

}

@property (nonatomic,retain) NSString *prefUnits;
@property (nonatomic,assign) NSString *prefRefreshInterval;
@property (nonatomic,assign) BOOL prefUse24hour;
@property (nonatomic,retain) NSMutableDictionary *prefTitles;
@property (nonatomic,retain) NSMutableDictionary *prefValues;

@end
