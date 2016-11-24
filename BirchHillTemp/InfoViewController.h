//
//  InfoViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 1/13/12.
//  Copyright (c) 2012 University of Alaska Fairbanks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Appirater.h"
#import "WEPopoverController.h"
#import "ColorViewController.h"

@class InfoViewController;

@protocol InfoViewControllerDelegate
-(void) infoViewControllerDidFinish:(InfoViewController *)controller;
@end


@interface InfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, ColorViewControllerDelegate>
{
    
    IBOutlet UILabel *versionLabel;
    IBOutlet UINavigationBar *navBar;
    
    IBOutlet UITableView *settingsTableView;

    UIPopoverController *colorPickerPopover;
    
    WEPopoverController *popoverController;

}

@property (nonatomic, strong) WEPopoverController *popoverController;

@property BOOL defaultsChanged;
@property (nonatomic, weak) IBOutlet id <InfoViewControllerDelegate> delegate;
@property (nonatomic, copy) UIColor *bubbleColor;
@property (nonatomic, copy) UIColor *bubbleTextColor;
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, copy) NSString *changeColor;

-(IBAction)rateNow:(id)sender;
-(IBAction)done:(id)sender;
-(IBAction)donate:(id)sender;

@end
