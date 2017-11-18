//
//  ForecastDetailViewController.m
//  BirchHillTemp
//
//  Created by Gary Holton on 19/01/2013.
//
//

#import "ForecastDetailViewController.h"
#import "HTTPFetcher.h"
#import "Helpers.h"
#import "ForecastViewController.h"

@interface ForecastDetailViewController ()

@end

@implementation ForecastDetailViewController
@synthesize detailText = _detailText, detailHeading = _detailHeading;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setTitle:NSLocalizedString(@"Warning", nil)];
    
    [webView setDelegate:self];
    
     
    BOOL contrast = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
    self.view.backgroundColor = contrast ? [UIColor blackColor] : [UIColor whiteColor];
    webView.backgroundColor = self.view.backgroundColor;
    
    webView.alpha = 0;
    // kludgy fiddle with the web view
    /*
    CGRect rect = webView.frame;
    double screenHeight = [[UIScreen mainScreen] bounds].size.height;
    webView.frame = CGRectMake(rect.origin.x, rect.origin.y + 20, rect.size.width, screenHeight - 44  );
     */
    
    
    NSString *alertText = [NSString stringWithFormat:@"<html><head><link rel='stylesheet' href='style.css' type='text/css'/><meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=3.0; user-scalable=1'/></head><body><h3>%@</h3><p>%@</p></body></html>", _detailHeading, _detailText];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"]];
    [webView loadHTMLString:alertText baseURL:url];
    
//    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:kForecastWarning]];
//    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLRequest:req receiver:self action:@selector(receiveResponse:)];
//    [fetcher start];
}

-(void)webViewDidStartLoad:(UIWebView *)aView
{
    [activityIndicator startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)aView
{
    [activityIndicator stopAnimating];
    [UIView animateWithDuration:0.25 animations:^(void){aView.alpha = 1;} ];
}
//- (void) receiveResponse:(HTTPFetcher *)myFetcher
//{
//    
//    NSString *htmlstr = [[NSString alloc] initWithData:[myFetcher data] encoding:NSASCIIStringEncoding];
//    NSLog(@"%@",htmlstr);
//    NSArray *captures = getCapturesFromRegex(@"(?s)(<div id=\"main.*?</div>)", htmlstr);
//    
//    NSMutableString *webText;
//    if (captures.count > 0)
//    {
//        webText = [captures objectAtIndex:0];
//        [webText stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ."]];
//    }
//    else
//        webText = [@"<H3>No additional data</h3>" mutableCopy];
//    
//    BOOL contrast = NO; // [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
//    
//    // add header to hold css
//    NSString *css = contrast ? @"contrast.css" : @"style.css";
//    NSString *header = [NSString stringWithFormat:@"<html><head><link rel='stylesheet' href='%@' type='text/css'/><meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=3.0; user-scalable=1'/></head><body>", css];
//    
//    NSString *htmlString = [NSString stringWithFormat:@"%@ %@ <br/><br/>", header, webText];
//    
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"]];
//    [webView loadHTMLString:htmlString baseURL:url];
//
//    
//}

-(void)viewDidAppear:(BOOL)animated
{
    //hide tab bar
    [UIView animateWithDuration:0.25 animations:^{
        CGRect bounds = [[UIScreen mainScreen] bounds];
        CGRect tabBarFrame = self.tabBarController.tabBar.frame;
        NSLog(@"tabbarframe: %f %f", tabBarFrame.origin.y, tabBarFrame.size.height);
        // CGRect navigationBarFrame = self.navigationController.navigationBar.frame;
        self.tabBarController.view.frame = CGRectMake(0,0,bounds.size.width,bounds.size.height+tabBarFrame.size.height);
        self.tabBarController.tabBar.alpha = 0;}
     ];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    // Reveal tab bar back
    [UIView animateWithDuration:0.5 animations:^{
        CGRect bounds = [[UIScreen mainScreen] bounds];
        // CGRect tabBarFrame = self.tabBarController.tabBar.frame;
        self.tabBarController.view.frame = CGRectMake(0,0,bounds.size.width,bounds.size.height);
        self.tabBarController.tabBar.alpha=1;
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
- (BOOL) shouldAutorotate {
    return IS_IPAD;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return IS_IPAD ? YES : (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
