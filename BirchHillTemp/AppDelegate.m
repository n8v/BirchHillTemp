//
//  AppDelegate.m
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"


@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // initialize defaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *dateKey    = @"dateKey";
    NSDate *lastRead    = (NSDate *)[prefs objectForKey:dateKey];
    if (lastRead == nil)     // App first run: set up user defaults.
    {
        NSMutableDictionary *appDefaults  = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        
        // do any other initialization you want to do here - e.g. the starting default values.
        // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"should_play_sounds"];
        
        [prefs setBool:NO forKey:kPrefUnits];  // Fahrenheit
        
        // [prefs setBool:YES forKey:kPrefChill];
        // [prefs setBool:YES forKey:kPrefIcon];
        
        
        // ipad colors
        static const float bubbles[] = {0.827451, 0.827451, 0.827451, 1};
        static const float text[] = {0,0,0,1};
        static const float background[] = {1,1,1,1};
        [prefs setFloat:bubbles[0] forKey:@"Bubble_Red"];
        [prefs setFloat:bubbles[1] forKey:@"Bubble_Green"];
        [prefs setFloat:bubbles[2] forKey:@"Bubble_Blue"];
        [prefs setFloat:bubbles[3] forKey:@"Bubble_Alpha"];
        [prefs setFloat:text[0] forKey:@"Text_Red"];
        [prefs setFloat:text[1] forKey:@"Text_Green"];
        [prefs setFloat:text[2] forKey:@"Text_Blue"];
        [prefs setFloat:text[3] forKey:@"Text_Alpha"];
        [prefs setFloat:background[0] forKey:@"Background_Red"];
        [prefs setFloat:background[1] forKey:@"Background_Green"];
        [prefs setFloat:background[2] forKey:@"Background_Blue"];
        [prefs setFloat:background[3] forKey:@"Background_Alpha"];
        
        
        // sync the defaults to disk
        [prefs registerDefaults:appDefaults];
        [prefs synchronize];
    }
    [prefs setObject:[NSDate date] forKey:dateKey];

    
    
    // [Appirater setDebug:YES];
    [Appirater setAppId:@"463390269"];
    [Appirater appLaunched:YES];
    
    // image view for transition
    UIImage *img;
    if (IS_IPAD)
    {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft ||
            [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
        {
            img = [UIImage imageNamed:@"Default-Landscape-ipad.png"];
        }
        else
        {
            img = [UIImage imageNamed:@"Default-Portrait-ipad.png"];
        }
    }
    else
    {
        img = [UIImage imageNamed:@"Default.png"];
    }
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:img];
    imageView.contentMode = UIViewContentModeBottom;
    //imageView.opaque = YES;
    [self.window.rootViewController.view addSubview:imageView];
    [UIView transitionWithView:self.window duration:1.0f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void){imageView.alpha=0.0f;}
                    completion:^(BOOL finished){[imageView removeFromSuperview];}];
    
    
    // check for network connection
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No internet connection"
        message:@"This app requires an active wi-fi or cellular data connection. Please check your settings."
        delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        
        NSLog(@"There IS intearnet connection");
        
        
    }
    
    
    
    
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    NSLog(@"App Resign active");
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    NSLog(@"App Entering background");
    
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    NSLog(@"App Entering foreground");
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"App Becoming active");
    [Appirater appEnteredForeground:YES];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


@end
