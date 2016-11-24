//
//  SecondViewController.h
//  Trails
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helpers.h"
#import "HTTPFetcher.h"

@interface TrailsViewController : UITableViewController <NSURLConnectionDelegate>

{
    IBOutlet UILabel *loadingLabel;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIWebView *webView;
    IBOutlet UINavigationBar *navBar;

}




@end
