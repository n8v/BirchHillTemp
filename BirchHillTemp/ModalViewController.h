#import <UIKit/UIKit.h>
#import "HTTPFetcher.h"
#import "CapturesFromRegex.h"
#import "Constants.h"

@class ModalViewController;

@protocol ModalViewControllerDelegate
- (void) modalViewControllerDidFinish:(ModalViewController *)controller;
@end

@interface ModalViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    NSString *pageTitle;
    NSString *urlString;
    NSString *htmlString;
    IBOutlet UINavigationItem *navBarTitle;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, assign) IBOutlet id <ModalViewControllerDelegate> delegate;

@property (nonatomic, assign) UIWebView *webView;

@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) NSString *htmlString;
@property (nonatomic, retain) NSString *pageTitle;


- (IBAction)done:(id)sender;

@end
