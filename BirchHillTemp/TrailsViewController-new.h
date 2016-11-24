//
//  SecondViewController.h
//  Trails
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "Constants.h"
#import "Helpers.h"

@interface TrailsViewController : UITableViewController <PullTableViewDelegate, NSURLConnectionDelegate>

{
    IBOutlet UILabel *loadingLabel;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIWebView *webView;
    IBOutlet UINavigationBar *navBar;

    PullTableView *pullTableView;
    
    UIRefreshControl *refreshControl;
}

@property (nonatomic, strong) IBOutlet PullTableView *pullTableView;

NSString *stripHTML(NSString *html);


@end
