//
//  TrailDetailViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 15/01/2013.
//
//

#import <UIKit/UIKit.h>
#import "SafariAlertView.h"

@interface TrailDetailViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
}
@property (nonatomic, copy) NSString *detailText;

@end
