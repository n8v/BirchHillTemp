//
//  DetailViewController.m
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
{
    NSMutableData *detailData;
    NSURLConnection *connection;
    NSString *css;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController



#pragma mark - Managing the detail item

- (void)setDetailURL:(NSString *)newDetailURL
{
    if (_detailURL != newDetailURL) {
        _detailURL = newDetailURL;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

-(void)setDetailTitle:(NSString *)detailTitle
{
//    self.navigationItem.title = detailTitle;
    self.navigationItem.title = NSLocalizedString(@"Loading...", @"loading");
    _detailTitle = detailTitle;
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"News", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
    
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark - webview delegate

- (void)webViewDidFinishLoad:(UIWebView *)aWebView 
{
    [activityIndicator stopAnimating];
    [UIView animateWithDuration:0.5 animations:^(void) {
        [aWebView setAlpha:1.0];
        self.navigationItem.title = _detailTitle;
    }];

}


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

#pragma mark - View lifecycle

-(void)awakeFromNib
{
    if (IS_IPAD)
        self.splitViewController.delegate = self;
    [super awakeFromNib];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [webView setDelegate:self];
    
    
    //BOOL contrast = IS_IPAD ? NO : [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
    BOOL contrast = NO;
    NSString *cssFile = contrast ? @"contrast.css" : @"style.css";
    css = [NSString stringWithContentsOfFile:cssFile encoding:NSASCIIStringEncoding error:nil];
    self.view.backgroundColor = contrast ? [UIColor blackColor] : [UIColor whiteColor];
    
    
//    NSLog(@"View: %f, %f, %f, %f", self.view.frame.origin.x,  self.view.frame.origin.y, self.view.frame.size.width,  self.view.frame.size.height);
//    NSLog(@"Webview: %f, %f, %f, %f", webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, webView.frame.size.height);

    
    if (!webView)
    {
        CGRect rect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        webView = [[UIWebView alloc] initWithFrame:rect];
        [webView setDelegate:self];
        [self.view addSubview:webView];
        
    }

    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(contrast ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray)];
    activityIndicator.center = webView.center;
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = YES;
    [self.view addSubview:activityIndicator];

    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Detail will appear");
    NSLog(@"View: %f, %f, %f, %f", self.view.frame.origin.x,  self.view.frame.origin.y, self.view.frame.size.width,  self.view.frame.size.height);
    NSLog(@"Webview: %f, %f, %f, %f", webView.frame.origin.x, webView.frame.origin.y, webView.frame.size.width, webView.frame.size.height);

    // if we do this on load then the webview hasn't resized, so activityIndicator goes in the wrong place
    activityIndicator.center = webView.center;
        
    if (_detailURL)
        [self configureView];
}

-(void)configureView
{
    // dim web view and start animating
    [UIView animateWithDuration:0.5 animations:^(void) {
        [webView setAlpha:0.25]; }];
    [activityIndicator startAnimating];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_detailURL]];
    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLRequest:req
                            receiver:self action:@selector(receivedNews:)];
    [fetcher start];

//    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
//        if (!connection)
//        {
//            NSLog(@"Unable to connect");
//            NSString *header = [NSString stringWithFormat: @"<html><head><styel type='text/css'>%@</style></head>", css];
//            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"]];
//            [webView loadHTMLString:[header stringByAppendingString: @"<body><h2>Unable to connect</h2></body></html>"] baseURL:url];
//        }
//        else
//        {
//            detailData = [[NSMutableData alloc] init];
//        }
}

-(void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [detailData appendData:data];
}





-(void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"Web detail will disappear");
}



#pragma mark - methods to handle connections

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [detailData setLength:0];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *) error
{
    NSString *header = [NSString stringWithFormat: @"<html><head><style type='text/css'>%@</style></head>", css];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"]];
    [webView loadHTMLString:[header stringByAppendingString:@"<body><h2>Connection failed</h2></body></html>"] baseURL:url];
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [activityIndicator stopAnimating];
	
}


-(void)receivedNews:(HTTPFetcher *)myFetcher
{
    NSString *htmlstr = [[NSString alloc] initWithData:[myFetcher data] encoding:NSUTF8StringEncoding];
//    NSLog(@"Returned html: %@", htmlstr);
    
//    NSString *regex = @"(?s)<h2.*?>(.*?)</h2>.*<span class=.createdate.>(.*?)</span>.*<div class=.article-content.>(.*?)</div>";
//    NSString *regex = @"(?s)<h2.*?>(.*?)</h2>.*?</div>.*?</div>(.*?)<dd class=.modified.>.*?Last updated: (.*?)\\s*?</dd>";
//    NSArray *arrayWeb = getCapturesFromRegex(regex , htmlstr);
//
    NSString *htmlHeader = [NSString stringWithFormat: @"<head><style type='text/css'>%@</style><meta name='viewport' content='width=device-width; initial-scale=1.0; maximum-scale=2.0; user-scalable=1'/></head>", css];
    if ([htmlstr length])
    {
        //NSString *createDate = [arrayWeb objectAtIndex:1];
//        NSString *pageHeader = [arrayWeb objectAtIndex:0];
//        NSString *body = [arrayWeb objectAtIndex:1];
//        NSString *pageFormat = @"<html>%@<body><h3>%@</h3>%@</body></html>";
//        NSString *htmlToLoad = [NSString stringWithFormat:pageFormat,htmlHeader,pageHeader, body] ;

//        // this base URL is crucial to make sure images and other page content load correctly
        NSURL *url = [NSURL URLWithString:kNSCFHomeUrl];
//        [webView loadHTMLString:htmlToLoad baseURL:url];
        [webView loadHTMLString:htmlstr baseURL:url];

//        NSLog(@"HTML to load: %@", htmlToLoad);
        CGRect rect = webView.frame;
        NSLog(@"Web view frame = %f, %f, %f, %f", rect
              .origin.x,rect.origin.y, rect.size.width, rect.size.height);
        
        // webView.frame = CGRectMake(0, 0, 768, 911);
        
        CGRect rect2 = webView.frame;
        NSLog(@"Web view frame = %f, %f, %f, %f", rect2
              .origin.x,rect2.origin.y, rect2.size.width, rect2.size.height);
        
    }
    else
    {
        [webView loadHTMLString:[NSString stringWithFormat:@"<html>%@<body><h3>Not found</h3><p>Unable to parse data</p></body></html>" , htmlHeader]
                        baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
    [activityIndicator stopAnimating];
}




- (void)dealloc
{
    detailData = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UIInterfaceOrientationIsPortrait( [UIApplication sharedApplication].statusBarOrientation ))
    {
        webView.frame = CGRectMake(0,0,768, 911);
    }
    else
    {
        webView.frame = CGRectMake(0,0,703, 655);
    }
    activityIndicator.center = webView.center;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; // UIInterfaceOrientationMaskAll;
}
- (BOOL) shouldAutorotate {
    return NO;  // IS_IPAD;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO; // IS_IPAD ? YES : (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
