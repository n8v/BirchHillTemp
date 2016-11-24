//
//  ForecastDetailViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 19/01/2013.
//
//

#import <UIKit/UIKit.h>

@interface ForecastDetailViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) NSString *detailHeading;

@end
