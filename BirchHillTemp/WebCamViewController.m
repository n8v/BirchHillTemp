//
//  WebCamViewController.m
//  BirchHillTemp
//
//  Created by Gary Holton on 12/4/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "WebCamViewController.h"
#import "FirstViewController.h"
#import "AppDelegate.h"



@implementation WebCamViewController


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
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    // double tap to reload webview
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTap:)];
    [tap setDelegate:self];
    [tap setNumberOfTapsRequired:2];
    [webCamView addGestureRecognizer:tap];

    

    [webCamView setAlpha:0];
    
    curTempLarge.text = @"";
    curTempSmall.text = @"";
    curTempLarge.alpha=0;
    curTempSmall.alpha=0;

    // temp inset into webcam view on pre iPhone 5
    // iPhone 5 displays temp below webcam
    curTempLarge.hidden = !IS_IPHONE_5;
    curTempSmall.hidden = IS_IPHONE_5;

    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshWebCam];


    //  get sunrise/sunset
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"h:mm a"];
    
    FirstViewController *vc = (FirstViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
    NSDate *sunsetDate = [df dateFromString:vc.sunsetTime];
    NSDate *sunriseDate = [df dateFromString:vc.sunriseTime];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [sunriseLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Rise", nil),  [df stringFromDate:sunriseDate] ]];
    [sunsetLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Set", nil),[df stringFromDate:sunsetDate]] ];
    

    [UIView animateWithDuration:0.5 animations:^(void){
            sunriseLabel.alpha = 1.0;sunsetLabel.alpha = 1.0;}];

    
}

- (void) refreshWebCam
{
    NSURL *url = [NSURL URLWithString:kWebCamURL];
    [webCamView setDelegate:self];
    [webCamActivity setHidden:NO];
    [webCamView loadRequest:[NSURLRequest requestWithURL:url]];
    
    
}

-(void)handleTap:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self refreshWebCam];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Web cam failed with error: %@", error.description);
    NSString *htmlString = [NSString stringWithFormat:@"<html><body><link rel='stylesheet' type='text/css' href='contrast.css'/></head><body><div style='margin-left:10px;margin-right:10px;align: center;'><br/><br/>%@</br/></div></body></html>", NSLocalizedString(@"We're sorry, the webcam is unavailable.", @"webcam fail")];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"]];
    [webView loadHTMLString:htmlString baseURL:url];
    [webCamActivity stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    [UIView animateWithDuration:1.0 animations:^(void) {aWebView.alpha= 1.0;}];
    
//    [UIView transitionFromView:[self.view viewWithTag:23] toView:aWebView duration:1.0 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
    
//    [UIView transitionWithView:self.view duration:1.0f
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^(void){aWebView.alpha=1.0f; [[self.view viewWithTag:23] setAlpha:0];}
//                    completion:^(BOOL finished){  NSLog(@"Transition complete"); [[self.view viewWithTag:23] removeFromSuperview];  }];
    
    [NSTimer scheduledTimerWithTimeInterval:kWebCamRefreshInterval target:self selector:@selector(refreshWebCam) userInfo:nil repeats:NO];


	[webCamActivity stopAnimating];
    
    // display temp
    FirstViewController *vc = (FirstViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
    curTempLarge.text = vc.currentTempString;
    curTempSmall.text = vc.currentTempString;
    [UIView animateWithDuration:1.0 animations:^(void){
        curTempLarge.alpha =1; curTempSmall.alpha=1.0;}];
    
}



- (void)webViewDidStartLoad:(UIWebView *)webView {
	[webCamActivity startAnimating];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


- (void)viewDidUnload
{
    curTempSmall = nil;
    curTempLarge = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
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
