//
//  ModalViewController.m
//  BHTempHD
//
//  Created by Gary Holton on 11/28/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "ModalViewController.h"

@implementation ModalViewController
@synthesize delegate = _delegate;
@synthesize webView;
@synthesize urlString, htmlString;
@synthesize pageTitle;

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate modalViewControllerDidFinish:self];
}

#pragma mark - web view methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator stopAnimating];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [activityIndicator startAnimating];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [webView setDelegate:self];
//    if (htmlString)
//    {
//        NSURL *url = [NSURL URLWithString:urlString];
//        [webView loadHTMLString:htmlString baseURL:url];
//    }
//    else
//    {
//        NSURL *url = [NSURL URLWithString:urlString];
//        NSURLRequest *req = [NSURLRequest requestWithURL:url];
//        [webView loadRequest:req];
//    }
//    if (pageTitle)
//    {
//        [navBarTitle setTitle:pageTitle];
//    }
//    NSLog(@"Page title: %@", pageTitle);

    
    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLString:kForecastText
                                                         receiver:self
                                                           action:@selector(receiveResponse:)];
    [fetcher start];
    [fetcher release];
    [activityIndicator startAnimating];

    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
}

- (void) receiveResponse:(HTTPFetcher *)myFetcher
{
    NSString *htmlstr = [[NSString alloc] initWithData:[myFetcher data] encoding:NSASCIIStringEncoding];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?s)<b class=.fcstdate.>\.*(.*?)\.*</b>([^<$]+)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *capturesArrayForecast = [regex matchesInString:htmlstr
                                                    options:0
                                                      range:NSMakeRange(0, [htmlstr length])];
    NSMutableString *html = [[NSMutableString alloc] initWithString:@""];
    
    if ([capturesArrayForecast count] > 0)
    {
        for (NSTextCheckingResult *result in capturesArrayForecast)
        {
            [html appendString:[NSString stringWithFormat:@"<tr><td>%@</td><td>%@</td></t>",
                                [htmlstr substringWithRange:[result rangeAtIndex:1]],
                                 [htmlstr substringWithRange:[result rangeAtIndex:2]] ] ];
        }
        
        
    }
    else
        [html setString:@"Forecast unavailable"];
    [htmlstr release];
    htmlstr = nil;

    [webView loadHTMLString:html baseURL:[NSURL URLWithString:kForecastText]];
    
    [html release], html=nil;
    
    
}

- (void)willResignActive:(NSNotification *)notification
{
    [self.delegate modalViewControllerDidFinish:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
