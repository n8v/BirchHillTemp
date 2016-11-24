//
//  TrailDetailViewController.m
//  BirchHillTemp
//
//  Created by Gary Holton on 15/01/2013.
//
//

#import "TrailDetailViewController.h"

@interface TrailDetailViewController ()

@end

@implementation TrailDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:NSLocalizedString(@"Birch Hill Trails", nil)];
    
    [webView setDelegate:self];
    
//    BOOL contrast = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
    BOOL contrast = NO;
    
     // add header to hold css
    NSString *css = contrast ? @"contrast.css" : @"style.css";
    NSString *header = [NSString stringWithFormat:@"<html><head><link rel='stylesheet' href='%@' type='text/css'/><meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=3.0; user-scalable=1'/></head><body>", css];
    
    NSString *htmlString = [NSString stringWithFormat:@"%@ %@ <br/><br/>", header, _detailText];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"]];
    [webView loadHTMLString:htmlString baseURL:url];
    
    self.view.backgroundColor = contrast ? [UIColor blackColor] : [UIColor whiteColor];
    webView.backgroundColor = self.view.backgroundColor;
    
    webView.alpha = 0;
    // kludgy fiddle with the web view
    CGRect rect = webView.frame;
    double screenHeight = [[UIScreen mainScreen] bounds].size.height;
    webView.frame = CGRectMake(rect.origin.x, rect.origin.y + 20, rect.size.width, screenHeight - 44  );
    
    
}


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
        
    completion:^(BOOL finished){
        [UIView animateWithDuration:0.25 animations:^(void){webView.alpha = 1;} ];
        
         }];
    
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

#pragma mark - web view delegate
-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
            SafariAlertView *alert = [[SafariAlertView alloc] initWithTitle:@"Open in Safari?"
                                                                    message:@"Open this link in web browser?"
                                                                   delegate:self
                                                                    request:request];
            [alert show];
            return NO;
    }
    else
        return YES;
}

- (void)alertView:(SafariAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [[UIApplication sharedApplication] openURL:alertView.request.URL];
    }
}

- (NSUInteger)supportedInterfaceOrientations {
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
