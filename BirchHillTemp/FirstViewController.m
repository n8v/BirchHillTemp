//
//  FirstViewController.m
//  Birch Hill Temp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "FirstViewController.h"
#import "HTTPFetcher.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FirstViewController () 
{
    NSDate *lastUpdated; // keep track of when temps were last updated
    NSTimer *refreshTimer;
    NSInteger connectionCount;
    BOOL isFirstLoad;
    BOOL needsRefresh;
    BOOL isCelsius;
    
}
@property (nonatomic, retain) NSTimer *refreshTimer;

@end

@implementation FirstViewController
@synthesize refreshTimer;


#pragma mark - info view

-(void)infoViewControllerDidFinish:(InfoViewController *)controller
{
    NSLog(@"Info view did finish");
    if (controller.defaultsChanged)
    {
        [self loadTemps];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)showInfo:(id)sender
{
    [self performSegueWithIdentifier:@"showInfo" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showInfo"])
    {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    NSLog(@"First vc did load");

    for (UIView *vw in self.view.subviews)
    {
        if (vw.tag > 20)
            vw.backgroundColor = [UIColor clearColor];
    }
    
    // initialize date
    // old date will trigger call to load temps
    lastUpdated = [NSDate distantPast];

    
    // keep track of curren temp so it can be accessed by web cam
    self.currentTempString = [[NSMutableString alloc] initWithCapacity:10];
    
    
    // keep track of first load, so that we can load temps even if refresh set to Never
    isFirstLoad = YES;
    needsRefresh = YES;
    
 
    
    // add units selector button
    unitsButton = [[UIBarButtonItem alloc] initWithTitle:@"°F" style:UIBarButtonItemStylePlain target:self action:@selector(changeUnits:)];
    [unitsButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], NSFontAttributeName,nil] forState:UIControlStateNormal];
    _navBarItem.rightBarButtonItem = unitsButton;
    
    // localize tab bar titles
#warning -  couldn't we do this in the app delegate?
    for (UITabBarItem *tb in self.tabBarController.tabBar.items)
    {
        [tb setTitle:NSLocalizedString([tb title], nil)];
    }
	
    // set up bubbles
//    for (UIView *vw in self.view.subviews)
//    {
//        if (vw.tag == 1) vw.backgroundColor = [UIColor clearColor];
//    }
    
    // these work for both iPhone and iPad
    // RoundedView class size based on size of container in storyboard
    currentTempRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, currentTempView.frame.size.width, currentTempView.frame.size.height) andFontSize:0 footer:YES header:NO];
    nwsTempRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, nwsTempView.frame.size.width, nwsTempView.frame.size.height) andFontSize:0]; // 44
    uafTempRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, uafTempView.frame.size.width, uafTempView.frame.size.height) andFontSize:0];
    goldstreamRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, gsTempView.frame.size.width, gsTempView.frame.size.height) andFontSize:0];
    [currentTempView addSubview:currentTempRounded];
    [nwsTempView addSubview:nwsTempRounded];
    [uafTempView addSubview:uafTempRounded];
    [gsTempView addSubview:goldstreamRounded];
    
    highTempRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, highTempView.frame.size.width, highTempView.frame.size.height) andFontSize:0]; // 44
    lowTempRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, lowTempView.frame.size.width, lowTempView.frame.size.height) andFontSize:0];
    humidityRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, humidityView.frame.size.width, humidityView.frame.size.height) andFontSize:0]; // 36
    [highTempView addSubview:highTempRounded];
    [lowTempView addSubview:lowTempRounded];
    [humidityView addSubview:humidityRounded];

    
    // windchill embedded in currentTemp view for iPhone; separate view for iPad
    // always visible on iPad
    if (IS_IPAD)
    {
        chillRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0,0,chillView.frame.size.width,chillView.frame.size.height) andFontSize:0 footer:NO];
        [chillView addSubview:chillRounded];
        chillRounded.headerText.text = NSLocalizedString(@"WINDCHILL", nil);
        chillRounded.mainText.textAlignment = NSTextAlignmentCenter;
        chillRounded.headerText.textAlignment = NSTextAlignmentCenter;
        chillRounded.alpha = 1;
    }
    else
    {
        chillRounded = [[RoundedView alloc] initWithFrame:CGRectMake(currentTempView.frame.size.width-70, 0, 60, 80) andFontSize:28 footer:NO];
        [currentTempView insertSubview:chillRounded aboveSubview:currentTempRounded];
        chillRounded.headerText.text = NSLocalizedString(@"CHILL", nil);
        chillRounded.mainText.textAlignment = NSTextAlignmentRight;
        chillRounded.headerText.textAlignment = NSTextAlignmentRight;
        chillRounded.alpha = 0;
    }
    
    // wind only shown on iPad and iPhone 5
    if (IS_IPHONE_5 || IS_IPAD)
    {
        windCurrentRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, windCurrentView.frame.size.width, windCurrentView.frame.size.height) andFontSize:0 footer:NO];
        [windCurrentRounded.headerText setText:NSLocalizedString(@"WIND", @"WIND")];
        [windCurrentView addSubview:windCurrentRounded];
        
        windAverageRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, windAverageView.frame.size.width,windAverageView.frame.size.height) andFontSize:0 footer:NO];
        [windAverageRounded.headerText setText:NSLocalizedString(@"AVERAGE", @"AVERAGE")];
        [windAverageView addSubview:windAverageRounded];
        windMaxRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, windMaxView.frame.size.width, windMaxView.frame.size.height) andFontSize:0 footer:NO];
        [windMaxRounded.headerText setText:NSLocalizedString(@"MAX",@"MAX")];
        [windMaxView addSubview:windMaxRounded];
        
        
    }
    else
    {
        // hide wind view for pre iPhone 5
        windCurrentView.hidden = YES;
        windAverageView.hidden = YES;
        windMaxView.hidden = YES;
    }

    
    if (IS_IPAD)
    {
        // add extra iPad stuff
        webCamContainer = [[RoundedView alloc] initWithFrame:CGRectMake(0,0,camView.frame.size.width, camView.frame.size.height)];
        NSLog(@"%f", NSFoundationVersionNumber);
        if (IS_IOS_8)
        {
            webCamView = [[UIWebView alloc] initWithFrame:CGRectMake(-210, 10, 540, 240)];
        }
        else
        { webCamView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 320, 240)];  }
        
        webCamView.backgroundColor = [UIColor clearColor];
        webCamView.opaque = NO;
        webCamView.userInteractionEnabled = NO;
        webCamView.layer.cornerRadius = 10;
        webCamView.clipsToBounds = YES;
        [webCamView setDelegate:self];
        [webCamContainer addSubview:webCamView];
        [camView addSubview:webCamContainer];
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = webCamView.center;
        activityIndicator.hidesWhenStopped = YES;
//        webCamContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [webCamContainer addSubview:activityIndicator];
        NSURL *url = [NSURL URLWithString:kWebCamURL];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [webCamView loadRequest:req];
        
        // sunrise
        sunriseContainer = [[RoundedView alloc] initWithFrame:CGRectMake(0,0,sunriseView.frame.size.width, sunriseView.frame.size.height)];
        sunriseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, sunriseView.frame.size.width-40, 65)];
        sunriseLabel.textAlignment = NSTextAlignmentLeft;
        sunriseLabel.textColor = [UIColor darkTextColor];
        sunriseLabel.backgroundColor = [UIColor clearColor];
        sunriseLabel.numberOfLines = 3;
        sunriseLabel.alpha = 1;
        sunriseLabel.tag = 11;
        [sunriseContainer addSubview:sunriseLabel];
        [sunriseView addSubview:sunriseContainer];
        
        forecastRounded = [[RoundedView alloc] initWithFrame:CGRectMake(0, 0, forecastView.frame.size.width, forecastView.frame.size.height)];
//        todayForecastTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20+65, sunriseView.frame.size.width-40, sunriseView.frame.size.height-40-65)];
        todayForecastTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 10, forecastRounded.frame.size.width-40, forecastRounded.frame.size.height-30)];
        
        todayForecastTextView.textAlignment = NSTextAlignmentLeft;
        todayForecastTextView.textColor = [UIColor darkTextColor];
        todayForecastTextView.backgroundColor = [UIColor clearColor];
        todayForecastTextView.scrollEnabled = YES;
        todayForecastTextView.font = [UIFont systemFontOfSize:16];
        todayForecastTextView.alpha = 1;
        todayForecastTextView.editable = NO;
        todayForecastTextView.selectable = NO;
        todayForecastTextView.contentInset = UIEdgeInsetsMake(0, -5, 0, 0);
        todayForecastTextView.tag = 11;

        [forecastRounded addSubview:todayForecastTextView];
        [forecastView addSubview:forecastRounded];
        
//        climateRounded = [[RoundedView alloc] initWithFrame:CGRectMake(myWidth-300, myHeight-400, 280, 100)];
//        climateTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,30,280,42)];
//        climateTextLabel.numberOfLines = 2;
//        climateTextLabel.textAlignment = NSTextAlignmentCenter;
//        climateTextLabel.backgroundColor = [UIColor clearColor];
//        climateTextLabel.textColor = [UIColor whiteColor];
//        [climateRounded addSubview:climateTextLabel];
//        [self.view addSubview:climateRounded];
        
        
        
    }
    else  // iphone
    {
        
        // localize the title
        _navBarItem.title = (NSLocalizedString(_navBarItem.title, nil));
        // Line3.hidden = !IS_IPHONE_5;
        

    }
    
    currentTempRounded.headerText.text = IS_IPAD ? @"BIRCH HILL" : @"";
    uafTempRounded.headerText.text = @"UAF";
    nwsTempRounded.headerText.text = NSLocalizedString(@"AIRPORT",nil);
    lowTempRounded.headerText.text = NSLocalizedString(@"LOW", nil);
    highTempRounded.headerText.text = NSLocalizedString(@"HIGH",nil);
    humidityRounded.headerText.text = NSLocalizedString(@"HUMIDITY", nil);
    goldstreamRounded.headerText.text = @"GS SPORTS";

    
    
    
    
    // check for custom alert
    HTTPFetcher *fetcherAlert = [[HTTPFetcher alloc] initWithURLString:kCustomAlert
                                                               timeout:60
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                              receiver:self
                                                                action:@selector(receivedAlert:)];
    [fetcherAlert start];
    
    

    
    
    
    
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"First view controller will appear");
    
    

    if (IS_IPAD)
    {
        // format for ipad
        
        // put localized date in title (on phone this goes in a separate label
        _navBarItem.title = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];

        // get default color
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

        _bubbleColor = [UIColor colorWithRed:[prefs floatForKey:@"Bubble_Red"] green:[prefs floatForKey:@"Bubble_Green"] blue:[prefs floatForKey:@"Bubble_Blue"] alpha:[prefs floatForKey:@"Bubble_Alpha"]];

        _bubbleTextColor = [UIColor colorWithRed:[prefs floatForKey:@"Text_Red"] green:[prefs floatForKey:@"Text_Green"] blue:[prefs floatForKey:@"Text_Blue"] alpha:[prefs floatForKey:@"Text_Alpha"]];
        
        _backgroundColor = [UIColor colorWithRed:[prefs floatForKey:@"Background_Red"] green:[prefs floatForKey:@"Background_Green"] blue:[prefs floatForKey:@"Background_Blue"] alpha:[prefs floatForKey:@"Background_Alpha"]];
        
        NSLog(@"FVC bubble color: %@", _bubbleColor);
        NSLog(@"FVC text color: %@", _bubbleTextColor);
        NSLog(@"FVC backgorund color: %@", _backgroundColor);

        self.view.backgroundColor = _backgroundColor;
        [self setBubbleColor:_bubbleColor];
        [self setBubbleTextColor:_bubbleTextColor];
        
        // self.view.backgroundColor = [prefs boolForKey:kPrefContrast] ? [UIColor blackColor] : GRAY_BACKGROUND;

        //self.view.backgroundColor = [UIColor whiteColor];
//        [self setBubbleColor:[UIColor colorWithWhite:.9 alpha:1]];
        

        
        NSLog(@"Last vc %@", [[self.tabBarController.viewControllers lastObject] description]);
        InfoViewController *ivc = [self.tabBarController.viewControllers lastObject];
        
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
            UIViewController *vc = (UIViewController *)[sb instantiateViewControllerWithIdentifier:@"landscape"];
            for (int i=21; i<=34; i++)
            {
                NSLog(@"Tag %d, %.f, %.f", i, [self.view viewWithTag:i].frame.origin.x, [vc.view viewWithTag:i].frame.origin.x);
                [self.view viewWithTag:i].frame = [vc.view viewWithTag:i].frame;
            }
            humidityView.hidden = YES;

        }
        
        
        if (ivc.defaultsChanged)
        {
            needsRefresh = YES;
            [self loadtempsIfNeeded];
        }
        
        
    }
    else
    {
        [todayLabel setText:[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterNoStyle ]];
        self.view.backgroundColor = GRAY_BACKGROUND;
        // bubbles not visible; just used as placeholders
        [self setBubbleColor:[UIColor clearColor]];
    }
    
    

    // common format iPhone/iPad
    
    isCelsius = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefUnits];
    unitsButton.title = isCelsius ?  @"°C" : @"°F";

    NSLog(@"Registering for app became active notif");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecameActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    
}


-(void)setBubbleColor:(UIColor *)aColor
{
    for (UIView *vw in self.view.subviews)
    {
        for (UIView *sv in vw.subviews)
        {
            if ([sv isKindOfClass:[RoundedView class]])
                sv.backgroundColor = aColor;
        }
    }

}

-(void)setBubbleTextColor:(UIColor *)aColor
{
    for (UIView *vw in self.view.subviews)
    {
        for (UIView *sv in vw.subviews)
        {
            for (UIView *svv in sv.subviews)
            {
                if (svv.tag == 11)
                {
                    UILabel *lbl = (UILabel *)svv;
                    lbl.textColor = aColor;
                }
            }
        }
    }
    
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    NSLog(@"Unregistering for become active notif");
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}



-(IBAction)tappedRefresh:(id)sender
{
    [self loadTemps];
}

- (void) loadTemps {
	
    if (_navBarItem.leftBarButtonItem.enabled == NO)
    {
        // still loading
        NSLog(@"Still loading..");
    }
    else
    {
        if (refreshTimer)
        {
            NSLog(@"Invalidating timer");
            [refreshTimer invalidate];
            refreshTimer = nil;
        }
        // start the activity indicator in the status bar
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        _navBarItem.leftBarButtonItem.enabled = NO;
        _navBarItem.rightBarButtonItem.enabled = NO;
        
        NSLog(@"Refreshing temps...");
        
        connectionCount = 0;

        HTTPFetcher *fetcherUAF = [[HTTPFetcher alloc] initWithURLString:kUAFurl
                                                           timeout:60
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                             receiver:self
                                                               action:@selector(receivedUAF:)];
        [fetcherUAF start];
        connectionCount += 1;

        HTTPFetcher *fetcherNWS = [[HTTPFetcher alloc] initWithURLString:kNWSxml
                                                                 timeout:60
                                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                receiver:self
                                                                  action:@selector(receivedNWS:)];
        [fetcherNWS start];
        connectionCount += 1;
        
        
        HTTPFetcher *fetcherNSCFraw = [[HTTPFetcher alloc] initWithURLString:kNSCFraw
                                                                        receiver:self
                                                                          action:@selector(receivedCumulusTxt:)];
        [fetcherNSCFraw start];
        connectionCount += 1;

        HTTPFetcher *fetcherGoldstreamSports = [[HTTPFetcher alloc] initWithURLString:kGoldstreamSportsWeather
                                                                              timeout:60
                                                                          cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                                     receiver:self
                                                                       action:@selector(receivedGoldstreamSports:)];
        [fetcherGoldstreamSports start];
        connectionCount += 1;
        
        
        if (IS_IPAD)
        {
            // get today's forecast
            HTTPFetcher *fetcherTodayForecast = [[HTTPFetcher alloc] initWithURLString:kForecastxml
                                                                                 receiver:self
                                                                                   action:@selector(receivedTodayForecast:)];
            [fetcherTodayForecast start];
            connectionCount += 1;
            
        }
        
        
/*
        // fetch weather icon
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kPrefIcon])
            {
            NSDate *beginDate = [NSDate date];
            NSDate *endDate = [beginDate dateByAddingTimeInterval:24*3600];
            NSString *dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:dateFormat];
            NSString *beginDateString =  [[df stringFromDate:beginDate] stringByReplacingOccurrencesOfString:@" " withString:@"T"];
            NSString *endDateString =  [[df stringFromDate:endDate] stringByReplacingOccurrencesOfString:@" " withString:@"T"];
            
            NSLog(@"Begin date string: %@",beginDate);
            NSString *urlString = [NSString stringWithFormat:kForecastIconURL, beginDateString, endDateString];
            HTTPFetcher *fetcherNWSicon = [[HTTPFetcher alloc] initWithURLString:urlString receiver:self action:@selector(receiveIcons:)];
            [fetcherNWSicon start];
                connectionCount += 1;
        }
  */     
        

        
    }
	
}	

#pragma mark - notifications


-(void)loadtempsIfNeeded
{
    if (_navBarItem.leftBarButtonItem.enabled)
    {
        if (lastUpdated == nil)
            lastUpdated = [NSDate distantPast];
        float secSinceUpdate =  -[lastUpdated timeIntervalSinceNow];
        NSLog(@"Last temp refresh %.f secs ago", secSinceUpdate);
        
        /*  no longer getting refresh interval from prefs
        int tempRefresh = [[[NSUserDefaults standardUserDefaults] objectForKey:KPrefRefreshInterval] integerValue];
        if ( needsRefresh || secSinceUpdate > 3600*7 ||  (secSinceUpdate >=  tempRefresh && tempRefresh > 0))
            [self loadTemps];
        */
        
        if (needsRefresh || secSinceUpdate > 3600*7 || secSinceUpdate > kRefreshInterval )
            [self loadTemps];
    }
    else
        NSLog(@"Temps already loading");
}

- (void)appBecameActive:(NSNotification *)notif
{
    NSLog(@"First view got becoming active notification");
    
    [self loadtempsIfNeeded];
    
}


#pragma mark - methods to handle connections

// called after all connections close
-(void)loadTempsFinished:(BOOL)success
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _navBarItem.leftBarButtonItem.enabled = YES;
    _navBarItem.rightBarButtonItem.enabled = YES;
    
    NSLog(@"Done loading temps");
    // keep reference so we can stop it if needed
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval
                                         target:self
                                       selector:@selector(loadTemps)
                                       userInfo:nil
                                        repeats:NO];
    if (success)
    {
        lastUpdated = [NSDate date];
        NSLog(@"Setting last updated to %@", lastUpdated);
        needsRefresh = NO;
    }
    
    
}


-(void)receivedGoldstreamSports:(HTTPFetcher *)myfetcher
{
    NSString *htmlString = [[NSString alloc] initWithData:[myfetcher data] encoding:NSASCIIStringEncoding];
    
    if (htmlString.length > 0)
    {
        
//        NSArray *timeArray = getCapturesFromRegex(@"<caption>Conditions at local time ([0-9][0-9]:[0-9][0-9]) on (.*?[0-9]{4})", htmlString);
//        NSArray *timeArray = getCapturesFromRegex(@"<span id=\"update-time\">([^<]+)</span>", htmlString);
        NSLog(@"%@", htmlString);
//        NSArray *timeArray = getCapturesFromRegex(@"<div class=\"local-time\">.*<span>((\\d{1,2}:\\d\\d \\w+ \\w+) on (\\w+ \\d{1,2}, \\d{4}))</span>", htmlString);
        NSArray *timeArray = getCapturesFromRegex(@"Updated: <b>((\\d{1,2}:\\d\\d \\w+ \\w+) on (\\w+ \\d{1,2}, \\d{4}))</b>", htmlString);
        if (timeArray.count > 0)
        {
            NSString *gsTime = [timeArray objectAtIndex:1];
            NSString *gsDate = [NSString stringWithFormat:@"%@ %@", [timeArray objectAtIndex:2], gsTime];
            
            NSLog(@"GS string: %@", gsDate);
//            NSArray *tempArray = getCapturesFromRegex(@"<td>Temperature</td>\n\\s*<td>([0-9\\.\\-]*?)&", htmlString);
//            if (tempArray.count > 0)  { NSLog(@"GS Temp: %@", [tempArray objectAtIndex:0]); }
            
            NSString *formatString = @"d MMMM yyyy' 'H:mm";
            if (secondsSinceTimeString(gsDate, formatString) > 24*3600)
            {
                // old date, don't use it
                [goldstreamRounded setMainTextWithFade:@"--"];
                [goldstreamRounded setFooterTextWithFade:@"--"];
                
            }
            else
            {
                /// date is good, so get the temp
//                NSArray *tempArray = getCapturesFromRegex(@"<td>Temperature</td>\n\\s*<td>([0-9\\.\\-]*?)&", htmlString);
//                NSArray *tempArray = getCapturesFromRegex(@"<span class=\"wx-value\">([\\d.-]+)</span>", htmlString);
                NSArray *tempArray = getCapturesFromRegex(@"<td[^>]*>Temperature</td>\\s*<td>\\s*<b>([\\d.-]+)</b>", htmlString);
                if (tempArray.count > 0)
                {
                    float tempF = [[tempArray objectAtIndex:0] floatValue];
                    [goldstreamRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", isCelsius ? FAHRENHEIT_TO_CELSIUS(tempF) : tempF ]];
                    
                }

            }
            [goldstreamRounded setFooterTextWithFade:formatTimeString(gsTime, @"H:mm")];
            
        }
        else {
            NSLog(@"No time/date found");
        }
    }

    connectionCount -= 1;
    if (connectionCount == 0)
        [self loadTempsFinished:YES];


}

-(void)receivedAlert:(HTTPFetcher *)myfetcher
{
    NSString *jsonString = [[NSString alloc] initWithData:[myfetcher data] encoding:NSASCIIStringEncoding];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:jsonData
                          options:NSJSONReadingAllowFragments
                          error:&error];
    
    if (error)
        NSLog(@"Json Error gettting custom alert: %@", error.description);
    

    NSLog(@"json: %@", json);
    
    
    if ([json objectForKey:@"message"] )
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *expireDate = [df dateFromString:[json objectForKey:@"expires"]];
        NSLog(@"Expire string: %@", [json objectForKey:@"expires"]);
        NSLog(@"Expire: %@", expireDate);
        NSLog(@"Now: %@", [NSDate date]);
        if ([expireDate timeIntervalSinceNow] > 0 || expireDate == NULL)
        {
        
        NSString *alertTitle = [json objectForKey:@"title"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:[json objectForKey:@"message"]
                                                        delegate:self
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:  nil];
        [alert show];
            
        }
        
    }
    
}

//-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    
//}

-(NSString *)getTempStringForKey:(NSString *)keyValue fromDictionary:(NSDictionary *)dictionary
{
    // get formatted temperature string for given json dictionary key value
    // use appropriate units (F / C)
    // return "--" if that is the value
    NSString *str = [dictionary objectForKey:keyValue];
    if ([str isEqualToString:@"--"] || fabs([str floatValue])>=100.0)
    {
        return @"--";
    }
    else
    {
        float temp = [[dictionary objectForKey:keyValue] floatValue];
        if (isCelsius)
            temp = FAHRENHEIT_TO_CELSIUS(temp);
        return [NSString stringWithFormat:@"%.f\u00B0",temp];
    }
}

-(void)receivedCumulusTxt:(HTTPFetcher *)myfetcher
// procss raw text file from NSCF weatherpage
{
    NSString *rawString = [[NSString alloc] initWithData:[myfetcher data] encoding:NSASCIIStringEncoding];
    NSString *chompedString = [[rawString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *tokens = [chompedString componentsSeparatedByString:@" "] ;
    NSArray *keys = [@"dateyyyymmdd timehhmmss temp hum dew wspeed wlatest bearing rrate rfall press currentwdir beaufortnumber windunit tempunitnodeg pressunit rainunit windrun presstrendval rmonth ryear rfally intemp inhum wchill temptrend tempth ttempth temptl ttemptl windtm twindtm wgusttm twgusttm pressth tpressth presstl tpresstl version build wgust heatindex humidex uv et solarrad avgbearing rhour forecastnumber isdaylight sensorcontactlost wdir cloudbasevalue cloudbaseunit apptemp sunshinehours currentsolarmax issunny" componentsSeparatedByString:@" "];
    NSDictionary* fields;
    
    if ([tokens count] == [keys count])
    {
        fields = [NSDictionary dictionaryWithObjects:tokens forKeys:keys];

        // high/low since midnight times  h:mm a
        NSString *highTime = [fields objectForKey:@"ttempth"];
        NSString *lowTime = [fields objectForKey:@"ttemptl"];
        [highTempRounded setFooterTextWithFade:formatTime(highTime)];
        [lowTempRounded setFooterTextWithFade:formatTime(lowTime)];
        
        // current temp time
        // NSString *tempTimeFormat = @"";  // may have a different format
        NSString *tempTime = [fields objectForKey:@"timehhmmss"];
        [currentTempRounded setFooterTextWithFade:formatTime(tempTime)];
        
        // current, high/low since midnight temps
        float tempF = [[fields valueForKey:@"temp"] floatValue];
//        float highTemp = [[fields valueForKey:@"hightemp"] floatValue];
//        float lowTemp = [[fields valueForKey:@"lowtemp"] floatValue];
//        float windChill = [[fields valueForKey:@"wchill"] floatValue];
        float windMph = [[fields valueForKey:@"wspeed"] floatValue];

        // wind chill
        bool displayChill =  IS_IPAD || [[NSUserDefaults standardUserDefaults] boolForKey:kPrefChill];
        if ( displayChill &&  (windMph>3 && tempF<=50 && windMph<110 && tempF>-50))
        {
//            if (isCelsius)
//                windChill = FAHRENHEIT_TO_CELSIUS(windChill);
            if (IS_IPAD)
            {
                [chillRounded setMainTextWithFade:[self getTempStringForKey:@"wchill" fromDictionary:fields]];
            }
            else
            {
                [chillRounded.mainText setText:[self getTempStringForKey:@"wchill" fromDictionary:fields]];
                [self fade:chillRounded];
            }
        }
        else
        {
            if (IS_IPAD)
            {
                [chillRounded setMainTextWithFade:@"--"];
            }
            else
            {
                [self fadeOut:chillRounded];
            }
        }
        
        
        // deal with erroneous high/low temp readings
        
//        if (fabsf(highTemp) >= 100.0)
//             [highTempRounded setMainTextWithFade:@"--"];
//        else if (isCelsius)
//            [highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(highTemp)]];
//        else
//            [highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", highTemp]];
//        
//        if (fabsf(lowTemp) >= 100.0)
//            [lowTempRounded setMainTextWithFade:@"--"];
//        else if (isCelsius)
//            [lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(lowTemp)]];
//        else
//            [lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", lowTemp]];
        
        NSString *currentTemp = [self getTempStringForKey:@"temp" fromDictionary:fields];
        self.currentTempString = [NSMutableString stringWithFormat:@"%@ %@",
                                  currentTemp,
                                  isCelsius ? @"C" : @"F"];
        [currentTempRounded setMainTextWithFade:currentTemp];
        [highTempRounded setMainTextWithFade:[self getTempStringForKey:@"tempth" fromDictionary:fields]];
        [lowTempRounded setMainTextWithFade:[self getTempStringForKey:@"temptl" fromDictionary:fields]];
//        if (isCelsius)
//        {
//            self.currentTempString = [NSMutableString stringWithFormat:@"%.f\u00B0 C",FAHRENHEIT_TO_CELSIUS(tempF)];
//            [currentTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(tempF)]];
//            //[highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(highTemp)]];
//            //[lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", FAHRENHEIT_TO_CELSIUS(lowTemp)]];
//            //[chillRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", FAHRENHEIT_TO_CELSIUS(windChill)]];
//        }
//        else
//        {
//            self.currentTempString = [NSMutableString stringWithFormat:@"%.f\u00B0 F",tempF];
//            [currentTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",tempF]];            
//            // [highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", highTemp]];
//            //[lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", lowTemp]];
//            //[chillRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", windChill]];
//        }
        
        
        // temp trend
        float tempChangeF = [[fields valueForKey:@"temptrend"] floatValue];
        
        if (tempChangeF > 1.0)
            [currentTempRounded setImage:[UIImage imageNamed:@"red_arrow.png"]];
        else if (tempChangeF < -1.0)
            [currentTempRounded setImage:[UIImage imageNamed:@"blue_arrow.png"]];
        else
            [currentTempRounded setImage:nil];

        // humidity
        float humidity = [[fields objectForKey:@"hum"] floatValue];
        [humidityRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f",humidity]];
        humidityRounded.unitsText.text = @"%";
        
        
        // wind speed/direction
        if (IS_IPHONE_5 || IS_IPAD)
        {
            
            float windAveMph = [[fields valueForKey:@"wspeed"] floatValue];
            float windMaxMph = [[fields valueForKey:@"wgust"] floatValue];
            int windDirection = [[fields valueForKey:@"bearing"] intValue];
            NSString *windDirectionLabel = [fields objectForKey:@"currentwdir"];
            
            NSLog(@"Wind direction: %@ (%d)", windDirectionLabel, windDirection);
            
            if (isCelsius)
            {
                [windCurrentRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", MPH_TO_MPS(windMph)]];
                [windAverageRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", MPH_TO_MPS(windAveMph)]];
                [windMaxRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", MPH_TO_MPS(windMaxMph)]];
                windCurrentRounded.unitsText.text = @"m  / s";
                windMaxRounded.unitsText.text = @"m  / s";
                windAverageRounded.unitsText.text = @"m  / s";
            }
            else
            {
                [windCurrentRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", windMph]];
                [windAverageRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", windAveMph]];
                [windMaxRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", windMaxMph]];
                windCurrentRounded.unitsText.text = @"mph";
                windMaxRounded.unitsText.text = @"mph";
                windAverageRounded.unitsText.text = @"mph";
            }

        }
        
        // sunrise/sunset times
//        if (!self.sunsetTime)
//        {
//            self.sunriseTime = formatTime([fields objectForKey:@"sunrise"]);
//            self.sunsetTime = formatTime([fields objectForKey:@"sunset"]);
//            NSArray *lodArray = [[fields objectForKey:@"daylight"] componentsSeparatedByString:@":"];
//            int lodHour = [[lodArray objectAtIndex:0] integerValue];
//            int lodMinute = [[lodArray objectAtIndex:1] integerValue];
//            NSString *lodHourPlural = (lodHour > 1) ? @"s" : @"";
//            NSString *lodMinutePlural = (lodMinute > 1) ? @"s" : @"";
//            self.lodTime = [NSString stringWithFormat:@"%d hour%@ %d minute%@", lodHour, lodHourPlural, lodMinute, lodMinutePlural];
//            NSLog(@"Sunrise/set from weather station: %@, %@", self.sunriseTime, self.sunsetTime);
//        }
//        if (IS_IPAD)
//        {
//            sunriseLabel.text =[NSString stringWithFormat:@"Sunrise: %@\nSunset: %@\nDaylight: %@", _sunriseTime, _sunsetTime, _lodTime];
//            sunriseContainer.alpha = 1;
//        }
        
        
        
   
    }

    connectionCount -= 1;
    if (connectionCount == 0)
        [self loadTempsFinished:YES];

}
/*
 {
 NSString *jsonString = [[NSString alloc] initWithData:[myfetcher data] encoding:NSASCIIStringEncoding];
 NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
 NSError *error;
 NSDictionary* json = [NSJSONSerialization
 JSONObjectWithData:jsonData
 options:NSJSONReadingAllowFragments
 error:&error];
 
 if (error)
 NSLog(@"Json Error: %@", error.description);
 
 if (json.count>0)
 {
 // high/low since midnight times  h:mm a
 NSString *highTime = [json objectForKey:@"hightime"];
 NSString *lowTime = [json objectForKey:@"lowtime"];
 [highTempRounded setFooterTextWithFade:formatTime(highTime)];
 [lowTempRounded setFooterTextWithFade:formatTime(lowTime)];
 
 // current temp time
 // NSString *tempTimeFormat = @"";  // may have a different format
 NSString *tempTime = [json objectForKey:@"temptime"];
 [currentTempRounded setFooterTextWithFade:formatTime(tempTime)];
 
 // current, high/low since midnight temps
 float tempF = [[json valueForKey:@"temp"] floatValue];
 //        float highTemp = [[json valueForKey:@"hightemp"] floatValue];
 //        float lowTemp = [[json valueForKey:@"lowtemp"] floatValue];
 //        float windChill = [[json valueForKey:@"chill"] floatValue];
 float windMph = [[json valueForKey:@"windcurrent"] floatValue];
 
 // wind chill
 bool displayChill =  IS_IPAD || [[NSUserDefaults standardUserDefaults] boolForKey:kPrefChill];
 if ( displayChill &&  (windMph>3 && tempF<=50 && windMph<110 && tempF>-50))
 {
 //            if (isCelsius)
 //                windChill = FAHRENHEIT_TO_CELSIUS(windChill);
 if (IS_IPAD)
 {
 [chillRounded setMainTextWithFade:[self getTempStringForKey:@"chill" fromDictionary:json]];
 }
 else
 {
 [chillRounded.mainText setText:[self getTempStringForKey:@"chill" fromDictionary:json]];
 [self fade:chillRounded];
 }
 }
 else
 {
 if (IS_IPAD)
 {
 [chillRounded setMainTextWithFade:@"--"];
 }
 else
 {
 [self fadeOut:chillRounded];
 }
 }
 
 
 // deal with erroneous high/low temp readings
 
 //        if (fabsf(highTemp) >= 100.0)
 //             [highTempRounded setMainTextWithFade:@"--"];
 //        else if (isCelsius)
 //            [highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(highTemp)]];
 //        else
 //            [highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", highTemp]];
 //
 //        if (fabsf(lowTemp) >= 100.0)
 //            [lowTempRounded setMainTextWithFade:@"--"];
 //        else if (isCelsius)
 //            [lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(lowTemp)]];
 //        else
 //            [lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", lowTemp]];
 
 NSString *currentTemp = [self getTempStringForKey:@"temp" fromDictionary:json];
 self.currentTempString = [NSMutableString stringWithFormat:@"%@ %@",
 currentTemp,
 isCelsius ? @"C" : @"F"];
 [currentTempRounded setMainTextWithFade:currentTemp];
 [highTempRounded setMainTextWithFade:[self getTempStringForKey:@"hightemp" fromDictionary:json]];
 [lowTempRounded setMainTextWithFade:[self getTempStringForKey:@"lowtemp" fromDictionary:json]];
 //        if (isCelsius)
 //        {
 //            self.currentTempString = [NSMutableString stringWithFormat:@"%.f\u00B0 C",FAHRENHEIT_TO_CELSIUS(tempF)];
 //            [currentTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(tempF)]];
 //            //[highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(highTemp)]];
 //            //[lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", FAHRENHEIT_TO_CELSIUS(lowTemp)]];
 //            //[chillRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", FAHRENHEIT_TO_CELSIUS(windChill)]];
 //        }
 //        else
 //        {
 //            self.currentTempString = [NSMutableString stringWithFormat:@"%.f\u00B0 F",tempF];
 //            [currentTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",tempF]];
 //            // [highTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", highTemp]];
 //            //[lowTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", lowTemp]];
 //            //[chillRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0", windChill]];
 //        }
 
 
 // temp trend
 float tempChangeF = [[json valueForKey:@"change"] floatValue];
 
 if (tempChangeF > 1.0)
 [currentTempRounded setImage:[UIImage imageNamed:@"red_arrow.png"]];
 else if (tempChangeF < -1.0)
 [currentTempRounded setImage:[UIImage imageNamed:@"blue_arrow.png"]];
 else
 [currentTempRounded setImage:nil];
 
 // humidity
 float humidity = [[json objectForKey:@"humidity"] floatValue];
 [humidityRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f",humidity]];
 humidityRounded.unitsText.text = @"%";
 
 
 // wind speed/direction
 if (IS_IPHONE_5 || IS_IPAD)
 {
 
 float windAveMph = [[json valueForKey:@"windmax"] floatValue];
 float windMaxMph = [[json valueForKey:@"windgust"] floatValue];
 int windDirection = [[json valueForKey:@"winddeg"] intValue];
 NSString *windDirectionLabel = [json objectForKey:@"windlabel"];
 
 NSLog(@"Wind direction: %@ (%d)", windDirectionLabel, windDirection);
 
 if (isCelsius)
 {
 [windCurrentRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", MPH_TO_MPS(windMph)]];
 [windAverageRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", MPH_TO_MPS(windAveMph)]];
 [windMaxRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", MPH_TO_MPS(windMaxMph)]];
 windCurrentRounded.unitsText.text = @"m  / s";
 windMaxRounded.unitsText.text = @"m  / s";
 windAverageRounded.unitsText.text = @"m  / s";
 }
 else
 {
 [windCurrentRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", windMph]];
 [windAverageRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", windAveMph]];
 [windMaxRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f", windMaxMph]];
 windCurrentRounded.unitsText.text = @"mph";
 windMaxRounded.unitsText.text = @"mph";
 windAverageRounded.unitsText.text = @"mph";
 }
 
 }
 
 // sunrise/sunset times
 if (!self.sunsetTime)
 {
 self.sunriseTime = formatTime([json objectForKey:@"sunrise"]);
 self.sunsetTime = formatTime([json objectForKey:@"sunset"]);
 NSArray *lodArray = [[json objectForKey:@"daylight"] componentsSeparatedByString:@":"];
 int lodHour = [[lodArray objectAtIndex:0] integerValue];
 int lodMinute = [[lodArray objectAtIndex:1] integerValue];
 NSString *lodHourPlural = (lodHour > 1) ? @"s" : @"";
 NSString *lodMinutePlural = (lodMinute > 1) ? @"s" : @"";
 self.lodTime = [NSString stringWithFormat:@"%d hour%@ %d minute%@", lodHour, lodHourPlural, lodMinute, lodMinutePlural];
 NSLog(@"Sunrise/set from weather station: %@, %@", self.sunriseTime, self.sunsetTime);
 }
 if (IS_IPAD)
 {
 sunriseLabel.text =[NSString stringWithFormat:@"Sunrise: %@\nSunset: %@\nDaylight: %@", _sunriseTime, _sunsetTime, _lodTime];
 sunriseContainer.alpha = 1;
 }
 
 
 
 
 }
 
 connectionCount -= 1;
 if (connectionCount == 0)
 [self loadTempsFinished:YES];
 
 }
 */

-(void) receivedNWS:(HTTPFetcher *)myfetcher
{
    NSString *htmlstr = [[NSString alloc] initWithData:[myfetcher data]
                                              encoding:NSASCIIStringEncoding];
    // this should be good XML, so we can parse it, but regex seems just as easy
    
    NSArray *arrayNWS = getCapturesFromRegex(@"(?s)([0-9]{1,2}:[0-9][0-9] [ap]m) AK[DS]T</observation_time>.*<temp_f>(.*)</temp_f>.*<temp_c>(.*)</temp_c>.*<icon_url_base>(.*?)</icon_url_base>.*<icon_url_name>(.*?)</icon_url_name>", htmlstr);
    
    if ( [arrayNWS count] >= 3 ) {
        NSString *temp = tempRounded([arrayNWS objectAtIndex:1]);
        NSString *tempC = tempRounded([arrayNWS objectAtIndex:2]);
        NSString *time = [[arrayNWS objectAtIndex:0] uppercaseString];
        [nwsTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%@\u00B0",  isCelsius ? tempC : temp]];
        [nwsTempRounded setFooterTextWithFade:formatTime(time)];
    }
    else
    {
        // nwsTempRounded.mainText.text = @"--";
        NSLog(@"Can't match airport temp");
    }
    
    
    // set icon
    if (arrayNWS.count >= 5 && [[NSUserDefaults standardUserDefaults] boolForKey:kPrefIcon] && !IS_IPAD)
    {
        NSString *base = [arrayNWS objectAtIndex:3];
        NSString *icon = [arrayNWS objectAtIndex:4];
        NSString *iconURLString = [base stringByAppendingPathComponent:icon];
        NSLog(@"Got icon: %@", iconURLString);
        NSURL *url = [NSURL URLWithString:iconURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *iconImage = [[UIImage alloc] initWithData:imageData];
        iconImageView.image = iconImage;
        [self fade:iconImageView];

    }
    else
    {
        [self fadeOut:iconImageView];
    }
    
    
    connectionCount -= 1;
    if (connectionCount == 0)
        [self loadTempsFinished:YES];
    
    
}


-(void) receivedUAF:(HTTPFetcher *)myfetcher
{
    NSString *htmlstr = [[NSString alloc] initWithData:[myfetcher data]
                                              encoding:NSASCIIStringEncoding];
    if ([htmlstr isEqualToString:@""])
    {
        //[uafTempRounded.mainText setText:@"--"];
    }
    else
    {
        // NSLog(@"UAF string: %@", htmlstr);

        //  NSString *UAFregex = @"(?s)Time on the Station (.*?)([ap]).*?Outside Temperature (.*?) ";
        
        // UAF weather station changed so added new regex 2014-10-04
        NSString *UAFregex = @"(?s)<strong>Temperature:</strong>.*?<b>(.*?) F</b>.*?([01][0-9]:[0-9][0-9]):[0-9][0-9]";
        NSArray *capturesArrayUAF = getCapturesFromRegex(UAFregex, htmlstr);
        
        
        if ([capturesArrayUAF count] > 0)
        {
            float tempUAF = [[capturesArrayUAF objectAtIndex:0] floatValue];
            NSLog(@"UAF TEMP: %f", tempUAF);
            NSString *time = [capturesArrayUAF objectAtIndex:1];  //  in format 00:00
            NSLog(@"UAF time: %@", time);
            
            if (isCelsius)
            {
                [uafTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",FAHRENHEIT_TO_CELSIUS(tempUAF)]] ;
            }
            else
            {
                [uafTempRounded setMainTextWithFade:[NSString stringWithFormat:@"%.f\u00B0",tempUAF]] ;
            }
            [uafTempRounded setFooterTextWithFade:formatTimeString(time,@"HH:mm")];
            
            
        }
        else
        {
            // [uafTempRounded.mainText setText:@"--"];
        }
        
    }
    
    
    connectionCount -= 1;
    if (connectionCount == 0)
    [self loadTempsFinished:YES];
    
    
} // done with UAF

-(void) receivedTodayForecast:(HTTPFetcher *)myfetcher
{
    NSString *htmlstr = [[NSString alloc] initWithData:[myfetcher data]
                                              encoding:NSASCIIStringEncoding];
    if ([htmlstr isEqualToString:@""])
    {
        todayForecastTextView.text = @"Current forecast unavailable";
    }
    else
    {
        // NSLog(@"Today: %@", htmlstr);

        NSError *error = NULL;
        NSRegularExpression *regexToday = [NSRegularExpression regularExpressionWithPattern:@"(?s)</guid>.*<description>\\s*(.*?)\\s*</description>"
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
        // add error handling
        
        NSArray *capturesArrayToday = [regexToday matchesInString:htmlstr
                                                      options:0
                                                        range:NSMakeRange(0,[htmlstr length])];

        if ([capturesArrayToday count] > 0) {
            NSTextCheckingResult *result = [capturesArrayToday objectAtIndex:0];
            NSString *forecast = [htmlstr substringWithRange:[result rangeAtIndex:1]];
            todayForecastTextView.text = [[forecast stringByReplacingOccurrencesOfString:@"\n" withString:@" "] stringByReplacingOccurrencesOfString:@"  " withString:@" "];
        }
    
    }

    
    connectionCount -= 1;
    if (connectionCount == 0)
        [self loadTempsFinished:YES];

    
} // done with today's forecast





#pragma mark - convenience methods

int secondsSinceTimeString(NSString *timeString, NSString *formatString)
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:formatString];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *myDate = [df dateFromString:timeString];
    NSTimeInterval interval = [myDate timeIntervalSinceNow];
    return -interval;
}

NSString *formatTimeString(NSString *timeString, NSString *formatString)
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:formatString];
    NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [df setLocale:loc];
    NSDate *myDate = [df dateFromString:timeString];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [df setLocale:[NSLocale currentLocale]];
    NSString *newTime = [df stringFromDate:myDate];
    return newTime;
}

NSString *formatTime(NSString *timeString)
{
    // formats a time in am/pm into current locale time format
    return formatTimeString(timeString, @"h:mm a");
}

-(void) fade:(UIView *)aView
{
    [self fadeIn:aView withDuration:0.5 andWait:0.0];
}

-(void)fadeOut:(UIView*)aView
{
    [UIView animateWithDuration:0.5 animations:^void{
        [aView setAlpha:0.0];}
     ];
}
-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration
      andWait:(NSTimeInterval)wait
{
    [viewToFadeIn setAlpha:0];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:wait];
    [UIView setAnimationDuration:duration];
    [viewToFadeIn setAlpha:1.0];
    [UIView commitAnimations];
    
}

// temperature conversion
NSString *tempInCelsius(NSString *temp) {
	float tempC = ( [temp floatValue] -32 )* 5.0 / 9 ;
    
    // this was giving "-0" for results between -0.5 and 0.0
	//return [NSString stringWithFormat:@"%.f",tempC];
    
    if (kCelsiusDecimalPlaces == 0)
    {
        int tempCrounded = (int)roundf(tempC);
        return [NSString stringWithFormat:@"%d",tempCrounded];
    }
    else
    {
        float rounded = roundf(tempC * powf(10.0f, (float)kCelsiusDecimalPlaces));
        float roundedBack = rounded / powf(10.0f, (float)kCelsiusDecimalPlaces);
        NSString *format = [NSString stringWithFormat:@"%%.%df", kCelsiusDecimalPlaces];
        return [NSString stringWithFormat:format, roundedBack];
    }
	
}

NSString *tempRounded(NSString *temp) {
    // this would only return "floor"
//    return [NSString stringWithFormat:@"%.f",[temp floatValue]];

    // replaced with "round" on 2013-01-03
    return [NSString stringWithFormat:@"%d", (int)roundf([temp floatValue])];
    
}

NSString *tempInFahrenheit(NSString *temp) {
	float tempF = ( [temp floatValue] *  9.0 / 5 ) + 32.0 ;
    int tempFint = (int)tempF;
    float tempFrounded = roundf(tempF);
    int tempFroundedint = (int)tempFrounded;
	NSLog(@"TempF: %.2f",tempF);
	NSLog(@"TempF int: %d",tempFint);
	NSLog(@"TempF rounded: %.2f",tempFrounded);
	NSLog(@"TempF rounded int: %d",tempFroundedint);
	return [NSString stringWithFormat:@"%.f",tempF];
	
}

/*
// 24 hour time
NSString *timeTo24Hour(NSString *timeString)
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"h:mm a"];
    [df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    NSDate *time = [df dateFromString:timeString];
    [df setDateFormat:@"HH:mm"];
    NSString *newTime = [df stringFromDate:time];
    [df release];
    df = nil;
    return newTime;
}
*/


- (IBAction) changeUnits:(id)sender{
    // swap units
    isCelsius = !isCelsius;
    
    // update button title
    unitsButton.title = isCelsius ?  @"°C" : @"°F";

	// update user defaults with change
    [[NSUserDefaults standardUserDefaults] setBool:isCelsius forKey:kPrefUnits];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	// then update temps
	[self loadTemps];
}


#pragma mark - web cam delegate
-(void)webViewDidStartLoad
{
    [activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad
{
    [activityIndicator startAnimating];
}


#pragma mark - More view lifecycle



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}



- (void)viewDidUnload
{
    [refreshTimer invalidate];
    refreshTimer = nil;
    
    _navBarItem = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSUserDefaultsDidChangeNotification 
                                                  object:nil];
//    receivedData = nil;
}

#pragma mark - rotation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // get locations from pre-layed out dummy VC's in the storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    NSString *orient = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? @"portrait" : @"landscape";
    UIViewController *vc = (UIViewController *)[sb instantiateViewControllerWithIdentifier:orient];
    for (int i=21; i<=34; i++)
    {
        NSLog(@"Tag %d, %.f, %.f", i, [self.view viewWithTag:i].frame.origin.x, [vc.view viewWithTag:i].frame.origin.x);
        [self.view viewWithTag:i].frame = [vc.view viewWithTag:i].frame;
    }
    humidityView.hidden = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    
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
