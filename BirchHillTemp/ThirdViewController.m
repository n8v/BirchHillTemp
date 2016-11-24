//
//  ThirdViewController.m
//  Current weather forecast
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "ThirdViewController.h"
//#import "EGORefreshTableHeaderView.h"

#define kForecastRefreshInterval 3 * 3600  // seconds

@interface ThirdViewController ()
{
    NSDate *forecastUpdated;
    
    NSMutableArray *tableEntries;
    
}
@property (nonatomic,strong) NSDate *forecastUpdated;

@end

@implementation ThirdViewController
@synthesize forecastUpdated;
//@synthesize pullTableView;


- (void) loadForecast
{
    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLString:kForecastText
                                                         receiver:self
                                                           action:@selector(receiveResponse:)];
    [fetcher start];
    NSLog(@"Starting the fetcher");
   // self.pullTableView.pullTableIsRefreshing = YES;
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
//    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
//    self.pullTableView.pullBackgroundColor = self.view.backgroundColor;
//    self.pullTableView.pullTextColor = [UIColor darkTextColor];
   
    tableEntries = [[NSMutableArray alloc] init];
    [tableEntries removeAllObjects];

    navBar.topItem.title = NSLocalizedString(navBar.topItem.title, @"NWS Forecast - Fairbanks");

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
     NSLog(@"3rd view controller did load");
    
    
    [self loadForecast];
    NSLog(@"Number of entries loaded: %d", tableEntries.count);
    if (tableEntries.count>0)
        [self.tableView reloadData];
}    

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"3rd view controller will appear");
    
//    if (self.pullTableView.pullLastRefreshDate == nil)
//    {
//        NSLog(@"First update");
//        [self loadForecast];
//    }
//    else
//    {
//        NSLog(@"Forecast last updated: %@", self.pullTableView.pullLastRefreshDate);
//        NSLog(@"Time since last forecast update: %.f minutes",[self.pullTableView.pullLastRefreshDate timeIntervalSinceNow]/-60.0);
//        if ( [self.pullTableView.pullLastRefreshDate timeIntervalSinceNow]/-3600.0 > kForecastRefreshInterval )
//        {
//            // more than six hours since update so reload
//            NSLog(@"More than %.f hours since last forecast update, so reloading...", kForecastRefreshInterval/3600.0);
//            [self loadForecast];
//        }
//    }
    
}    




- (void) receiveResponse:(HTTPFetcher *)myFetcher
{

    NSString *htmlstr = [[[[NSString alloc] initWithData:[myFetcher data] encoding:NSASCIIStringEncoding]
            componentsSeparatedByString:@"FPAK53PAFG_AKZ222"] objectAtIndex:1];
    //NSLog(@"Weather HTML: %@", htmlstr);
    
    NSError *error = NULL;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(?s)<b class=.fcst(date|warn).>\\.*(.*?)\\.*</b>([^<$]+)"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error ];
    
    NSArray *capturesArrayForecast = [[NSArray alloc] initWithArray:[regex matchesInString:htmlstr
                                                                         options:0
                                                                           range:NSMakeRange(0, [htmlstr length])] ] ;
    
    NSMutableArray *tempEntries = [[NSMutableArray alloc] init];

    if ([capturesArrayForecast count] > 0)
    {
        for (NSTextCheckingResult *result in capturesArrayForecast)
        {
            NSString *fcastEntry = [[htmlstr substringWithRange:[result rangeAtIndex:3]] lowercaseString];
            NSString *fcastDateString = [[htmlstr substringWithRange:[result rangeAtIndex:2]]
                                         stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSLog(@"Date: %@\nEntry: %@\n", fcastDateString, fcastEntry);

            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES '^[0-9]{3,4} .*'"];
            if ([pred evaluateWithObject:fcastDateString])
            {
                // this is just the update string
                // reformat date
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
                [df setDateFormat:@"hmm a z EEE MMM d yyyy"];
                NSDate *myDate = [df dateFromString:fcastDateString];
                [df setLocale:[NSLocale currentLocale]];
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDateFormatter localizedStringFromDate:myDate
                                                                  dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle], @"subtitle",
                                    @"Forecast date", @"title", @"NO", @"warning",nil];
                [tempEntries addObject:dict];
            }
            else if ([[htmlstr substringWithRange:[result rangeAtIndex:1]] isEqualToString:@"warn"])
            {
                // it's a warning
                [tempEntries addObject:[NSDictionary dictionaryWithObjectsAndKeys: @"", @"subtitle", @"YES", @"warning", fcastDateString, @"title", nil]];
            }
            else if ([[htmlstr substringWithRange:[result rangeAtIndex:1]] isEqualToString:@"date"])
            {
                NSArray *days = [[fcastDateString capitalizedString] componentsSeparatedByString:@" And "];
                NSMutableString *outputDate = [NSLocalizedString([days objectAtIndex:0], nil) mutableCopy];
                if ([days count] > 1)
                {
                    [outputDate appendString:@" "];
                    [outputDate appendString:NSLocalizedString(@"and", @"and")];
                    [outputDate appendString:@" "];
                    [outputDate appendString:NSLocalizedString([days objectAtIndex:1], nil)];
                }
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:outputDate, @"title", fcastEntry, @"subtitle", @"NO", @"warning", nil];
                [tempEntries addObject:dict];
            
            }
            
              
        }
        
        
    }
    else
    {
        [tempEntries addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"NO", @"warning", @"Forecast unavailable", @"title", @"", @"subtitle", nil]];
    }
    
    tableEntries = [tempEntries mutableCopy];
    
    NSLog(@"%d table entries", tableEntries.count);
    
//    if (![[[NSLocale currentLocale] identifier] isEqualToString:@"en_US"])
//        [html appendString:[NSString stringWithFormat:@"<br/><br/><hr><p><i>%@</i></p>", NSLocalizedString(@"Temperatures in Fahrenheit", @"Temperatures in Fahrenheit")]];

    //NSLog(@"HTML: %@",html);
    capturesArrayForecast = nil;
    regex = nil;
    htmlstr = nil;
    
//    self.pullTableView.pullLastRefreshDate = [NSDate date];
//    self.pullTableView.pullTableIsRefreshing = NO;
//
//   [self.tableView reloadData];
    
    
    
}

//-(void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
//{
//    [self performSelector:@selector(loadForecast) withObject:nil afterDelay:2.0];
//}
//
//-(void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
//{
//    // do nothing
//}


- (NSMutableArray *) getCapturesFromRegex:(NSString *)regexString fromString:(NSString *)fromString {
    NSMutableArray *capturesArray = [[NSMutableArray alloc] initWithObjects: nil] ;
    NSError *error = NULL;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexString
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error ];
    if (!error) {
        NSArray *resultArray = [[NSArray alloc] initWithArray:[regex matchesInString:fromString
                                                                             options:0
                                                                               range:NSMakeRange(0, [fromString length])] ] ;
        if ([resultArray count] > 0) {
            // mostly just interested in first match
            NSTextCheckingResult *result = [resultArray objectAtIndex:0];
            // NSLog(@"%@",result);
            // NSLog(@"Number of ranges: %d", [result numberOfRanges]);
            for (int i=1; i< [result numberOfRanges]; i++) {
                //           NSLog(@"Range %d, %@",i,[result rangeAtIndex:i]);
                NSString *capture = [fromString substringWithRange:[result rangeAtIndex:i]];
                
                // NSLog(@"Captures array: %@",capturesArray);
                [capturesArray addObject:capture];
            }
            
        }
        resultArray = nil;
    }
    regex = nil;
    return capturesArray;
}

#pragma mark - table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableEntries count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeatherCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    // Configure the cell...
     
    cell.textLabel.text = [[tableEntries objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.detailTextLabel.text = [[tableEntries objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
    
    if ([[[tableEntries objectAtIndex:indexPath.row] objectForKey:@"warning"] isEqualToString:@"YES"])
        cell.textLabel.textColor = [UIColor redColor];
    
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;

    return  cell;

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float h = 14;
    if ( [[[tableEntries objectAtIndex:indexPath.row] objectForKey:@"warning"] isEqualToString:@"YES"])
    {
        NSString *str = [[tableEntries objectAtIndex:indexPath.row] objectForKey:@"title"];
        CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:UILineBreakModeWordWrap];
        h = size.height;
    }
    else
    {
        NSString *str = [[tableEntries objectAtIndex:indexPath.row] objectForKey:@"subtitle"];
        CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:UILineBreakModeWordWrap];
        h = size.height;
    }
    return h + 30;
}



- (void)viewDidUnload
{
    tableEntries = nil;
    navBar = nil;
    loadingLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - memory
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
