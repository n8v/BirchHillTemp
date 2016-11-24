//
//  Settings.m
//  BirchHillTemp
//
//  Created by Gary Holton on 12/30/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//
//    holds user settings 
//
//        Units
//        RefreshInterval
//        24hour
//
//        values
//        titles
//


#import "Settings.h"

@implementation Settings
@synthesize prefUnits,prefUse24hour,prefRefreshInterval;
@synthesize prefTitles,prefValues;

-(id)init
{
    self = [super init];
    if (self)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        prefRefreshInterval = [defaults objectForKey:@"RefreshInterval"];
        prefUse24hour = [defaults boolForKey:@"Use24hour"];
        prefUnits = [defaults stringForKey:@"Units"];
        
        if (prefUnits == nil)
        {
            NSLog(@"App settings have not been initialized.");
        }
        
        
        // list of titles and values is in Settings.bundle
        
        NSString *pathStr = [[NSBundle mainBundle] bundlePath];
        NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
        NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
        
        NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        
        prefValues = [NSDictionary dictionaryWithObjectsAndKeys:      
                      [[prefSpecifierArray objectAtIndex:1] objectForKey:@"Values"],  @"Units", 
                      [[prefSpecifierArray objectAtIndex:2] objectForKey:@"Values"], @"RefreshInterval",
                      nil];
        prefTitles = [NSDictionary dictionaryWithObjectsAndKeys:      
                      [[prefSpecifierArray objectAtIndex:1] objectForKey:@"Titles"],  @"Units", 
                       [[prefSpecifierArray objectAtIndex:2] objectForKey:@"Titles"], @"RefreshInterval",
                       nil];
                
        
    }
    return  self;
}


-(void) dealloc
{
    [prefTitles release];
    [prefUnits release];
    [prefValues release];
}

@end
