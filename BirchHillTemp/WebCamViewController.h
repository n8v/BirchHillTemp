//
//  WebCamViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 12/4/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//
//  only used for iPhone; iPad has its own webcam viewer in FirstViewController
//
#import <UIKit/UIKit.h>

@interface WebCamViewController : UIViewController <UIWebViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIWebView *webCamView;
    IBOutlet UIActivityIndicatorView *webCamActivity;
    IBOutlet UILabel *sunriseLabel;
    IBOutlet UILabel *sunsetLabel;
    IBOutlet UILabel *curTempSmall;
    IBOutlet UILabel *curTempLarge;
}

- (void) refreshWebCam;
//NSString *timeTo12Hour(NSString *timeString);


@end

