//
//  DetailViewController.h
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SafariAlertView.h"
#import "Helpers.h"
#import "HTTPFetcher.h"

@interface DetailViewController : UIViewController <UIWebViewDelegate, UISplitViewControllerDelegate>
{
    
//    NSString *detailURL;
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
}

@property (nonatomic, strong) NSString *detailURL;
@property (nonatomic, strong) NSString *detailTitle;


@end
