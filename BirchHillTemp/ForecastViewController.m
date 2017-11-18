//
//  ForecastViewController.m
//  BirchHillTemp
//
//  Created by Gary Holton on 14/01/2013.
//
//

#import "ForecastViewController.h"

@interface ForecastViewController ()
{
    NSMutableArray *tableData;
    BOOL contrast;
    NSDate *lastUpdated;
    NSMutableString *alertSummary;
    NSMutableString *alertTitle;
    NSMutableString *alertEvent;
    BOOL isAlert;
}
@end

@implementation ForecastViewController

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];

    alertSummary = [[NSMutableString alloc] init];
    alertEvent = [[NSMutableString alloc] init];
    alertTitle = [[NSMutableString alloc] init];
    isAlert = NO;
    
    self.navigationItem.title = IS_IPAD ? NSLocalizedString(@"National Weather Service Forecast - Middle Tanana Valley", nil) : NSLocalizedString(@"NWS Forecast - Fairbanks", nil);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"pull to refresh"];
        [self.refreshControl addTarget:self action:@selector(loadForecast)
                      forControlEvents:UIControlEventValueChanged];
        [self.refreshControl beginRefreshing];
    }
    else
    {
        UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadForecast)];
        self.navigationItem.leftBarButtonItem = but;
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    tableData = [[NSMutableArray alloc] init];

}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"3rd view controller will appear");
    
    contrast = NO; //IS_IPAD ? NO : [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
    self.view.backgroundColor = contrast ? [UIColor blackColor] : GRAY_BACKGROUND;
    
    [self.tableView reloadData];
    
    if (lastUpdated == nil)
    {
        NSLog(@"First forecast update");
        [self loadForecast];
    }
    else
    {
        NSLog(@"Forecast last updated: %@", lastUpdated);
        NSLog(@"Time since last forecast update: %.f second",-[lastUpdated timeIntervalSinceNow]);
        if ( -[lastUpdated timeIntervalSinceNow] > kForecastRefreshInterval )
        {
            // more than six hours since update so reload
            NSLog(@"More than %.f hours since last forecast update, so reloading...", kForecastRefreshInterval/3600.0);
            [self loadForecast];
        }
    }
    
}    

- (void) loadForecast
{
    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLString:kAlertXML  //kForecastZone  //kForecastText
                                                         receiver:self
                                                           action:@selector(receiveResponseAlert:)];
    [fetcher start];

    
    NSLog(@"Loading forecast");
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        [self.refreshControl beginRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"loading..."];
    }
    else
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // add 1 to account for warning at first index
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0 && isAlert)
    {
        // warning cell
        static NSString *CellIdentifier = @"WarningCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        // Configure the cell...
        
        cell.textLabel.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.detailTextLabel.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:.15 alpha:1];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        return cell;
    }
    else
    {
        // regular cell
        static NSString *CellIdentifier = @"WeatherCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        // Configure the cell...
        
        cell.textLabel.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.detailTextLabel.text = [[tableData objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;

        
        cell.textLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor blackColor];
        cell.detailTextLabel.textColor = contrast ? [UIColor colorWithWhite:0.85 alpha:1] : [UIColor colorWithWhite:0.15 alpha:1];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];

        
        return cell;
    }
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float h = 44;
    float myWidth = tableView.frame.size.width - 40;

     NSString *strTitle = [[tableData objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString *strSubTitle = [[tableData objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
    
    CGSize sizeTitle = [strTitle sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(myWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGSize sizeSubTitle = [strSubTitle sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(myWidth, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    h = sizeTitle.height + sizeSubTitle.height + 10;
    
    
    return h;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (IS_IPAD)
//    {
//        if (indexPath.row == 0 && isAlert)
//        {
//            NSString *title = [[tableData objectAtIndex:indexPath.row] objectForKey:@"title"];
//            NSString *subtitle = [[tableData objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
//            NSMutableString *newSub;
//            if ([subtitle isEqualToString:alertTitle])
//            {
//                newSub = alertSummary;
//                // [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textAlignment = NSTextAlignmentLeft;
//            }
//            else
//            {
//                newSub = alertTitle;
//                //[tableView cellForRowAtIndexPath:indexPath].detailTextLabel.textAlignment = NSTextAlignmentCenter;
//            }
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: title, @"title", newSub, @"subtitle", nil];
//            [tableData replaceObjectAtIndex:indexPath.row withObject:dict];
//            
//            [tableView reloadData];
//            
//        }
//    }

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showForecastDetail"])
    {
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: NSLocalizedString(@"Back",@"Back")
                                       style: UIBarButtonItemStylePlain
                                       target: nil action: nil];
        [self.navigationItem setBackBarButtonItem: backButton];
        [segue.destinationViewController setDetailText:alertSummary];
        [segue.destinationViewController setDetailHeading:alertEvent];
        

    }
}




#pragma mark - handle connection response from fetcher

-(void)receiveResponseAlert:(HTTPFetcher *)myFetcher
{
    NSString *htmlstr = [[NSString alloc] initWithData:[myFetcher data] encoding:NSASCIIStringEncoding];
    

    alertTitle = [getFirstCaptureFromRegex(@"(?s)<entry>.*?<title>(.*?)</title>", htmlstr) mutableCopy];
    alertEvent = [getFirstCaptureFromRegex(@"(?s)<entry>.*?<cap:event>(.*?)</cap:event>", htmlstr) mutableCopy];
    alertSummary = [getFirstCaptureFromRegex(@"(?s)<entry>.*?<summary>(.*?)</summary>", htmlstr) mutableCopy];
    alertSummary = [[alertSummary stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ."]] mutableCopy];
    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLString:kForecastZone
                                                                receiver:self
                                                                  action:@selector(receiveResponse:)];
    [fetcher start];

}
- (void) receiveResponse:(HTTPFetcher *)myFetcher
{
    
    NSString *htmlstr = [[NSString alloc] initWithData:[myFetcher data] encoding:NSASCIIStringEncoding];
    
    // first get date
    NSArray *captures = getCapturesFromRegex(@"(?s)<b>Last Update: (.*?)</td>(.*?)<b>Zone Forecast", htmlstr);
    
    // check for warning and load if necessary
    isAlert = ([htmlstr rangeOfString:@"class=\"warn\""].location != NSNotFound);
    
//    NSArray *captureForecast = getCapturesFromRegex(@"(?s)<b>Last Update: </b></a>(.*?)</td></tr>(.*?)<b>Zone Forecast:", htmlstr);
//    
//    if ([captureForecast count] == 0)
//    {
//        // throw an error
//        NSLog(@"Throw and error");
//        
//    }
//    NSString *forecastTime = [captureForecast objectAtIndex:0];
//    NSString *forecastBody = [captureForecast objectAtIndex:1];
//    
//    NSLog(@"Forecast body = %@",forecastBody);
    
    NSError *error = NULL;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"<b>(.*?)</b>(.*?)<br>"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error ];

    NSString *trimmedhtml = [captures objectAtIndex:1];
    NSArray *capturesArrayForecast = [[NSArray alloc] initWithArray:[regex matchesInString:trimmedhtml
                                                                                   options:0
                                                                                     range:NSMakeRange(0, [trimmedhtml length])] ];

    if ([capturesArrayForecast count] > 0)
    {
        NSMutableArray *tempEntries = [[NSMutableArray alloc] init];
        if (isAlert)
        {
            NSString *subtitle = IS_IPAD ? alertSummary : alertTitle;
            NSMutableDictionary *dictAlert = [[NSMutableDictionary alloc] initWithObjectsAndKeys:alertEvent,@"title", subtitle, @"subtitle", nil];
            [tempEntries addObject:dictAlert];
        }
        for (NSTextCheckingResult *result in capturesArrayForecast)
        {
//            NSLog(@"%@, %@", [htmlstr substringWithRange:[result rangeAtIndex:1]], [htmlstr substringWithRange:[result rangeAtIndex:2]] );
            NSString *fcastDateString = [[trimmedhtml substringWithRange:[result rangeAtIndex:1]] stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSString *fcastEntry = [trimmedhtml substringWithRange:[result rangeAtIndex:2]];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:fcastDateString, @"title", [fcastEntry stringByReplacingOccurrencesOfString:@"<br>" withString:@""], @"subtitle", nil];
                [tempEntries addObject:dict];
                
        
        }

        tableData = nil;
        tableData = [tempEntries mutableCopy];

    }

    else
    {
        // forecast unavailable
        NSLog(@"Forecast unavailable");
    }
    htmlstr = nil;
    
    
    lastUpdated =  [NSDate date];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        [self.refreshControl endRefreshing];
        NSString *updateText = [NSString stringWithFormat:@"Last updated %@\npull to refresh", timeSinceUpdate(lastUpdated)];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:updateText];
    }
    else
    {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    [self.tableView reloadData];
    
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.tableView setAlpha:1.0];
    }];
    
}


//- (void) receiveResponse:(HTTPFetcher *)myFetcher
//{
//#warning need to ensure that there really are 3 components returned!!!
//    // index 1 should be info at the top of forecast
//    NSArray *htmlArray = [[[NSString alloc] initWithData:[myFetcher data] encoding:NSASCIIStringEncoding] componentsSeparatedByString:@"PAFG_AKZ222"];
//    NSString *htmlstr = [htmlArray lastObject];
//
//                          
//    
//    NSError *error = NULL;
//    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?s)<b class=.fcst(date|warn).>\\.*(.*?)\\.*</b>([^<$]+)"
//                                                                      options:NSRegularExpressionCaseInsensitive
//                                                                        error:&error ];
//    
//    NSArray *capturesArrayForecast = [[NSArray alloc] initWithArray:[regex matchesInString:htmlstr
//                                                                                   options:0
//                                                                                     range:NSMakeRange(0, [htmlstr length])] ];
//    
//    NSMutableArray *tempEntries = [[NSMutableArray alloc] init];
//    
//    if ([capturesArrayForecast count] > 0)
//    {
//        for (NSTextCheckingResult *result in capturesArrayForecast)
//        {
//            NSString *warn = [htmlstr substringWithRange:[result rangeAtIndex:1]];
//            NSString *fcastEntry = [[[htmlstr substringWithRange:[result rangeAtIndex:3]] lowercaseString] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//            NSString *fcastDateString = [[htmlstr substringWithRange:[result rangeAtIndex:2]]
//                                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//            //NSLog(@"Warn: %@, Date: %@\nEntry: %@\n", warn, fcastDateString, fcastEntry);
//            
//            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES '^[0-9]{3,4} .*'"];
//            if ([pred evaluateWithObject:fcastDateString])
//            {
//                // this is just the date updated string
//                // we're ignoring this now
//                
//                // reformat date
//                /*
//                 NSDateFormatter *df = [[NSDateFormatter alloc] init];
//                [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//                [df setDateFormat:@"hmm a z EEE MMM d yyyy"];
//                NSDate *myDate = [df dateFromString:fcastDateString];
//                [df setLocale:[NSLocale currentLocale]];
//                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDateFormatter localizedStringFromDate:myDate
//                                                                                                               dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle], @"subtitle",
//                                      @"Forecast date", @"title", @"NO", @"warning",nil];
//                [tempEntries addObject:dict];
//                */
//            }
//            else if ([warn isEqualToString:@"warn"])
//            {
//                // it's a warning
//                if (IS_IPAD)
//                {
//                    [tempEntries addObject:[NSDictionary dictionaryWithObjectsAndKeys: @"[click for more]", @"subtitle", @"YES", @"warning", fcastDateString, @"title", nil]];
//                    
//                }
//                else
//                {
//                    [tempEntries addObject:[NSDictionary dictionaryWithObjectsAndKeys: @"", @"subtitle", @"YES", @"warning", fcastDateString, @"title", nil]];
//                    
//                }
//                if (htmlArray.count >= 3)
//                {
//                    NSArray *warningArray = getCapturesFromRegex(@"(?s)fcstwarn\">.*?</b>\\n*(.*?)\\$\\$", [htmlArray objectAtIndex:1]);
//                    if (warningArray.count > 0)
//                        warningString = [warningArray objectAtIndex:0];
//                }
//            }
//            else if ([warn isEqualToString:@"date"])
//            {
//                // it's just a regular entry
//                NSArray *days = [[fcastDateString capitalizedString] componentsSeparatedByString:@" And "];
//                NSMutableString *outputDate = [NSLocalizedString([days objectAtIndex:0], nil) mutableCopy];
//                if ([days count] > 1)
//                {
//                    [outputDate appendString:@" "];
//                    [outputDate appendString:NSLocalizedString(@"and", @"and")];
//                    [outputDate appendString:@" "];
//                    [outputDate appendString:NSLocalizedString([days objectAtIndex:1], nil)];
//                }
//                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:outputDate, @"title", fcastEntry, @"subtitle", @"NO", @"warning", nil];
//                [tempEntries addObject:dict];
//                
//            }
//            
//    
//    
//        } // end for
//        
//        
//    }
//    else
//    {
//        [tempEntries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"NO", @"warning", @"Forecast unavailable", @"title", @"", @"subtitle", nil]];
//    }
//    
//    tableData = [tempEntries mutableCopy];
//    
//    //NSLog(@"%d table entries", tableData.count);
//    
//    //    if (![[[NSLocale currentLocale] identifier] isEqualToString:@"en_US"])
//    //        [html appendString:[NSString stringWithFormat:@"<br/><br/><hr><p><i>%@</i></p>", NSLocalizedString(@"Temperatures in Fahrenheit", @"Temperatures in Fahrenheit")]];
//
//    htmlstr = nil;
//    
//    lastUpdated =  [NSDate date];
//    if (IS_IOS_6)
//    {
//        [self.refreshControl endRefreshing];
//        NSString *updateText = [NSString stringWithFormat:@"Last updated %@\npull to refresh", timeSinceUpdate(lastUpdated)];
//        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:updateText];
//    }
//    else if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
//        self.navigationItem.leftBarButtonItem.enabled = YES;
//
//    [self.tableView reloadData];
//    
//    
//    [UIView animateWithDuration:1.0 animations:^{
//        [self.tableView setAlpha:1.0];
//    }];
//    
//    
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return IS_IPAD ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}
- (BOOL) shouldAutorotate {
    return IS_IPAD;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return  IS_IPAD ? YES : (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
