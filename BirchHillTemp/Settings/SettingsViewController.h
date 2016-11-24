//
//  SettingsViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 12/28/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SettingsDetailViewController.h"

@class SettingsViewController;

@protocol SettingsViewControllerDelegate
-(void) settingsViewControllerDidFinish:(SettingsViewController *)controller;
@end

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tv;

    NSInteger selectedRow;    

}

@property (nonatomic, assign) IBOutlet id <SettingsViewControllerDelegate> delegate;

@property (nonatomic, retain) UITableView *tv;

-(IBAction)done:(id)sender;

@end
