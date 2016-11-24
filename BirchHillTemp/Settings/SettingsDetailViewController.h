//
//  SettingsDetailViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 12/29/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@class Settings;

@interface SettingsDetailViewController : UITableViewController
{
    NSString *curSettingKey;
    NSInteger curSettingIndex;
    NSMutableArray *values;
    NSMutableArray *titles;
}

@property (nonatomic, retain) NSString *curSettingKey;
@property (nonatomic, retain) NSMutableArray *values;
@property (nonatomic, retain) NSMutableArray *titles;
@property (nonatomic, assign) NSInteger curSettingIndex;

@end
