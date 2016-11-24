//
//  ThirdViewController.h
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "HTTPFetcher.h"
//#import "PullTableView.h"

@interface ThirdViewController : UITableViewController // <PullTableViewDelegate>
{
    IBOutlet UILabel *loadingLabel;
    IBOutlet UIActivityIndicatorView *forecastActivity;
    IBOutlet UIWebView *webView;
    IBOutlet UINavigationBar *navBar;
    
//    PullTableView *pullTableView;
    
}

//@property (nonatomic, retain) IBOutlet PullTableView *pullTableView;

- (void) receiveResponse:(HTTPFetcher *)myFetcher;

- (NSMutableArray *) getCapturesFromRegex:(NSString *)regexString fromString:(NSString *)fromString;

- (void) loadForecast ; 

@end
