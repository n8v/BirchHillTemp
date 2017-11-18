//
//  ListViewController.m
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "ListViewController.h"

// date format of RSS entries
#define kRSSDateFormat @"EEE, dd MMM yyyy HH:mm:ss zzz"


@interface ListViewController ()
{
    NSMutableArray *allEntries;  // tableview data source
    NSMutableString *entryUpdateString;
    NSDate *entryUpdate;
     BOOL contrast;
    NSDate *lastUpdated;
}

@end
@implementation ListViewController


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
   
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"pull to refresh"];
        [self.refreshControl addTarget:self action:@selector(fetchEntries)
                      forControlEvents:UIControlEventValueChanged];
    }
    else
    {
        UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchEntries)];
        self.navigationItem.leftBarButtonItem = but;
    }

    self.view.backgroundColor = GRAY_BACKGROUND;
    
    _detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    //if (!IS_IPAD)
        [self.navigationItem setTitle:NSLocalizedString(@"NSCF News", @"NSCF News")];
    
    // try to get entries from archive
    if (!allEntries)
    {
        NSLog(@"Checking archive");
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [docPath stringByAppendingPathComponent:@"rss.data"];
        NSMutableArray *allEntriesWithDate = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (allEntriesWithDate)
        {
            lastUpdated = [[allEntriesWithDate lastObject] copy];
            [allEntriesWithDate removeLastObject];
            allEntries = [allEntriesWithDate mutableCopy];
        }
        
    }
    if (!allEntries)
    {
        NSLog(@"None on disk; creating allEntries");
        allEntries = [[NSMutableArray alloc] init];
        lastUpdated = [NSDate date];
        
    }
    else if (IS_IPAD && allEntries.count > 0)
     {
         // on ipad go ahead and select first entry
         NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
         [self.tableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionNone];
         [_detailViewController setDetailURL:[[allEntries objectAtIndex:0] objectForKey:@"link"]];
         
         // set localized date for detail view
         NSString *entryDateStr = [[allEntries objectAtIndex:0] valueForKey:@"pubDate"];
         NSDateFormatter *df = [[NSDateFormatter alloc] init];
         [df setDateFormat:kRSSDateFormat];
         [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
         NSDate *entryDate = [df dateFromString:entryDateStr];
         [df setLocale:[NSLocale currentLocale]];
         [df setDateStyle:NSDateFormatterMediumStyle];
         [_detailViewController setDetailTitle:[df stringFromDate:entryDate]];

     }
    

    
    
    if ( -[lastUpdated timeIntervalSinceNow] > 3600 || allEntries.count == 0)
    {
        NSLog(@"Time interval since update: %f", -[lastUpdated timeIntervalSinceNow]);
        [self fetchEntries];
    }
 
    
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    contrast = IS_IPAD ? NO : [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
//    self.view.backgroundColor = contrast ? [UIColor blackColor] : [UIColor whiteColor]; // GRAY_BACKGROUND;
    
    
    [self.tableView reloadData];

}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"ListViewController disappearing");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [allEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsCell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = cleanHTML([[allEntries objectAtIndex:indexPath.row] valueForKey:@"title"]);
    
    // Configure cell detail text with the date
    NSString *itemDateStr = [[allEntries objectAtIndex:indexPath.row] valueForKey:@"pubDate"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:kRSSDateFormat];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *itemDate = [df dateFromString:itemDateStr];
    [df setLocale:[NSLocale currentLocale]];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [[cell detailTextLabel] setText:[df stringFromDate:itemDate]];

    cell.textLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor blackColor];
    cell.detailTextLabel.textColor = contrast ? [UIColor colorWithWhite:0.85 alpha:1] : [UIColor colorWithWhite:0.15 alpha:1];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // probably shouldn't hard code this width, but for now it's the same on iPhone and iPad
    #define tableWidth 280.0
    
    NSAttributedString *str = [[allEntries objectAtIndex:indexPath.row] valueForKey:@"title"];
//    CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(tableWidth, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    CGRect rect = [str boundingRectWithSize:CGSizeMake(tableWidth, 999) options: 0 context:nil];
    NSLog(@"size height %f",rect.size.height);
    return rect.size.height + 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // shoud be called only on iPad
    
    if (IS_IPAD)
    {
        NSLog(@"Row %d", (int) indexPath.row);
        NSString *urlString = [[allEntries objectAtIndex:indexPath.row] valueForKey:@"link"];
        [_detailViewController setDetailURL:urlString];
        NSLog(@"URL: %@", urlString);
        
        // format the date
        NSString *entryDateStr = [[allEntries objectAtIndex:indexPath.row] valueForKey:@"pubDate"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:kRSSDateFormat];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *entryDate = [df dateFromString:entryDateStr];
        [df setLocale:[NSLocale currentLocale]];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [_detailViewController setDetailTitle:[df stringFromDate:entryDate]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // segue called only for iPhone
    
    
    if ([[segue identifier] isEqualToString:@"showRSSdetail"])
    {
        NSInteger selectedRow = self.tableView.indexPathForSelectedRow.row;
        [[segue destinationViewController] setDetailURL:[[allEntries objectAtIndex:selectedRow] valueForKey:@"link"]];

        /* // format the date
        NSString *entryDateStr = [[allEntries objectAtIndex:selectedRow] valueForKey:@"pubDate"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:kRSSDateFormat];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]]; 
        NSDate *entryDate = [df dateFromString:entryDateStr];
        [df setLocale:[NSLocale currentLocale]];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [[[segue destinationViewController] navigationItem] setTitle:[df stringFromDate:entryDate]];
        */
        
        // set localized date for detail view
        NSString *entryDateStr = [[allEntries objectAtIndex:0] valueForKey:@"pubDate"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:kRSSDateFormat];
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        NSDate *entryDate = [df dateFromString:entryDateStr];
        [df setLocale:[NSLocale currentLocale]];
        [df setDateStyle:NSDateFormatterMediumStyle];
        [[segue destinationViewController] setDetailTitle:[df stringFromDate:entryDate]];

        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: NSLocalizedString(@"Back",@"Back")
                                       style: UIBarButtonItemStylePlain
                                       target: nil action: nil];
        [self.navigationItem setBackBarButtonItem: backButton];

    }
}

#pragma mark - connection methods

- (void)fetchEntries
{
    NSURL *url = [NSURL URLWithString:kNSCFxml];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLRequest:req
                                                          receiver:self
                                                            action:@selector(receiveResponse:)];
    [fetcher start];
    
    if (IS_IOS_6)
    {
        [self.refreshControl beginRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"loading..."];
    }
    else if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.title = NSLocalizedString(@"Loading...", @"loading");
    }

}


- (void)receiveResponse:(HTTPFetcher *)myFetcher
{    
    NSString *xmlstr = [[NSString alloc] initWithData:[myFetcher data] encoding:NSASCIIStringEncoding];
    NSArray *rawItems = [xmlstr componentsSeparatedByString:@"<item>"];
    
    if (rawItems.count > 1)
    {
        NSMutableArray *newEntries = [[NSMutableArray alloc] init];
        for (int i=1; i< rawItems.count; i++)
        {
            NSArray *captures = [self getCapturesFromRegex:@"(?s)<title>(.*?)</title>.*?<link>(.*?)</link>.*?<pubDate>(.*?)</pubdate>" fromString:[rawItems objectAtIndex:i]];
            if (captures.count == 3)
            {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[captures objectAtIndex:0], @"title",
                                      [captures objectAtIndex:1], @"link", [captures objectAtIndex:2], @"pubDate", nil];
                [newEntries addObject:dict];
            }
        }
        allEntries = [newEntries mutableCopy];
    }

    
    [self.tableView reloadData];

    if (IS_IOS_6)
    {
        [self.refreshControl endRefreshing];
        NSString *updateText = [NSString stringWithFormat:@"Last updated %@\npull to refresh", timeSinceUpdate(lastUpdated)];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:updateText];
    }
    else if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [self.navigationItem setTitle:NSLocalizedString(@"NSCF News", @"NSCF News")];
    }


    [UIView animateWithDuration:1.0 animations:^(void){
        [self.tableView setAlpha:1.0];}];

    NSLog(@"Done fetching RSS entries.");

    // archive entries for later use
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"rss.data"];
    NSMutableArray *archiveEntries = [allEntries mutableCopy];
    lastUpdated = [NSDate date];
    [archiveEntries addObject:lastUpdated];
    NSLog(@"Write to archive path: %@", filePath);
    BOOL success = [NSKeyedArchiver archiveRootObject:archiveEntries toFile:filePath];
    NSLog(@"Write to archive %@", success ? @"succeeded" : @"failed");

    
}



#pragma mark - parsing

NSString *cleanHTML(NSString *str)
{
    NSMutableString *cleaned = [[NSMutableString alloc] initWithString:str];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        @"\"",@"&quot;",
    @"&", @"&amp;", nil];
    for (NSString *key in [dict allKeys])
    {
        while ([cleaned rangeOfString:key].location != NSNotFound) {
            [cleaned replaceCharactersInRange:[cleaned rangeOfString:key] withString:[dict objectForKey:key]];
        }
    }
    return cleaned;
}

- (NSMutableArray *) getCapturesFromRegex:(NSString *)regexString fromString:(NSString *)fromString {
    NSMutableArray *capturesArray = [[NSMutableArray alloc] init] ;
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
