//
//  SecondViewController.m
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "TrailsViewController.h"
#import "TrailDetailViewController.h"

#define kTrailsRefreshInterval 3600

#define kMapText @"<img src='trail_map.png' width='529' height='575'></body></html>"

@interface TrailsViewController ()
{
    NSMutableArray *trailsArray;
    NSMutableArray *tableSections;
    NSMutableData *receivedData;
    BOOL includeOverview;
    BOOL includeMaps;
    NSMutableString *overviewText;
    BOOL contrast;
    NSDate *lastUpdated;

}

@end

@implementation TrailsViewController



#pragma mark - table view datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (includeOverview)
    {
        //NSLog(@"Rows in section %d: %d", section, section == 0 ? 1 : [[[tableSections objectAtIndex:section-1] objectForKey:@"trails"] count] );
        return section == 0 ? 1 : [[[tableSections objectAtIndex:section-1] objectForKey:@"trails"] count];
    }
    else
    {
        //NSLog(@"Rows in section %d: %d", section,[[[tableSections objectAtIndex:section] objectForKey:@"trails"] count] );
        return [[[tableSections objectAtIndex:section] objectForKey:@"trails"] count];
    }

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (includeOverview)
    {
        return (section == 0) ? @"Overview" : [[tableSections objectAtIndex:section-1] objectForKey:@"section_name"];
    }
    else
    {
        return [[tableSections objectAtIndex:section] objectForKey:@"section_name"];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableSections count] + (includeOverview ? 1 : 0) + (includeMaps ? 1 : 0);
}

/*
 -(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    int i;
    for (i=0; i< tableSections.count; i++)
    {
        if ([[[tableSections objectAtIndex:i] objectForKey:@"section_name"] isEqualToString:title])
            break;
    }
    return i;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Cell %d - %d", indexPath.section, indexPath.row);
    long mySection = indexPath.section - ( includeOverview ? 1 : 0);
    if (includeOverview && indexPath.section == 0 && ![overviewText isEqualToString:@""])
    {
            static NSString *CellIdentifier = @"OverviewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
            }
            
            
            // Configure the cell...
        cell.textLabel.text = stripHTML(overviewText);
        CGRect rect = cell.contentView.frame;
        cell.contentView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width-40, rect.size.height);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (IS_IPAD)
        {
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines =0;
        }
        else
        {
            cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            cell.textLabel.numberOfLines =3;
        }
        
        // color
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor blackColor];
        
        return  cell;
    }
    
    else if ( [[[tableSections objectAtIndex:mySection] objectForKey:@"section_name"] isEqualToString:@"Maps"])
    {
        static NSString *CellIdentifier = @"MapCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        
        // Configure the cell...
        cell.textLabel.text = [[[[tableSections objectAtIndex:mySection] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = nil;
        
        // color
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor =  contrast ? [UIColor whiteColor] : [UIColor blackColor];
        
        return  cell;
        
    }
    else
    {
        // regular trail cell
        
        long mySection = includeOverview ? indexPath.section - 1 : indexPath.section;
        static NSString *CellIdentifier = @"TrailCell";
        UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle        reuseIdentifier:CellIdentifier];
//            UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-40, 5, 40, 21)];
//            NSLog(@"Length label size: %d, %d, %d, %d", lengthLabel.frame.origin.x, lengthLabel.frame.origin.y,lengthLabel.frame.size.width, lengthLabel.frame.size.height);
//            lengthLabel.tag = 21;
//            lengthLabel.textColor = [UIColor darkGrayColor]; // contrast ? [UIColor whiteColor] : [UIColor darkGrayColor];
//            lengthLabel.backgroundColor = [UIColor clearColor];
//            lengthLabel.font = [UIFont systemFontOfSize:16];
//            [cell.contentView addSubview:lengthLabel];
//            
//            lengthLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin);
//            lengthLabel.text = @"length";
//            lengthLabel.textAlignment = UITextAlignmentRight;
        }
        
        
        // Configure the cell...
        
        // find the section
        NSString *trailName = [[[[tableSections objectAtIndex:mySection] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSString *trailTitle = [[[[tableSections objectAtIndex:mySection] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"title"];
        NSString *trailDifficulty = [[[[tableSections objectAtIndex:mySection] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"difficulty"];
        
        // length in meters
        float myLength = [[[[[tableSections objectAtIndex:mySection] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"length" ] floatValue];
        if (IS_IPAD)
        {
            float myLengthMiles = roundf(myLength /  1609.34 * 10.0) /10.0;
            [(UILabel *)[cell.contentView viewWithTag:21] setText:[NSString stringWithFormat:@"%.f meters (%0.1f miles)", myLength, myLengthMiles]];
            
        }
        else
        {
            float myLengthKm = roundf( myLength / 100.0) / 10; // leave one decimal place
            [(UILabel *)[cell.contentView viewWithTag:21] setText:[NSString stringWithFormat:@"%0.1f k", myLengthKm] ];
        }
        [(UILabel *)[cell.contentView viewWithTag:21] setTextColor:contrast ? [UIColor whiteColor] : [UIColor darkGrayColor]];
        [(UILabel *)[cell.contentView viewWithTag:22] setText:trailDifficulty];
        
        // difficulty graphic
        NSString *difficulty = [[[[tableSections objectAtIndex:mySection] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"difficulty"];
        unsigned long diffIndex = [[NSArray arrayWithObjects:@"EASY", @"MORE DIFFICULT", @"DIFFICULT",  @"MOST DIFFICULT", @"VERY DIFFICULT", @"",nil]
                         indexOfObject:difficulty];
        
        switch (diffIndex) {
            case 0:
                [cell.imageView setImage:[UIImage imageNamed:@"green-dot.png"]];
                break;
            case 1:
                [cell.imageView setImage:[UIImage imageNamed:@"green-dot.png"]];
                break;
            case 2:
                [cell.imageView setImage:[UIImage imageNamed:@"blue-square.png"]];
                break;
            case 3:
                [cell.imageView setImage:[UIImage imageNamed:@"black-diamond.png"]];
                break;
            case 4:
                [cell.imageView setImage:[UIImage imageNamed:@"double-black-diamond.png"]];
                break;
            default:
                [cell.imageView setImage:nil];
                break;
        }
         cell.imageView.backgroundColor = contrast ? [UIColor whiteColor] : [UIColor clearColor];
        
        
        cell.textLabel.text = trailTitle;
        for (NSDictionary *trail in trailsArray)
        {
            //NSLog(@"Comparing: %@ (%d), %@ (%d)", [trail objectForKey:@"name"], [[[trail objectForKey:@"name"] string] length], trailName, [trailName length]);
//            if ([[trail objectForKey:@"name"] isEqual:trailName])
            if ([[trail objectForKey:@"name"] rangeOfString:trailName].location != NSNotFound)
            {
                
                NSArray *captures = getCapturesFromRegex(@"([0-9]{1,2}/[0-9]{1,2})/[0-9][0-9]", [trail objectForKey:@"date"]);
                NSString *dateLabel = (captures.count > 0) ? [captures objectAtIndex:0] : [trail objectForKey:@"date"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                                             [trail objectForKey:@"condition"],
                                             dateLabel];
                
                cell.detailTextLabel.textColor = contrast ? [UIColor colorWithWhite:0.85 alpha:1] : [UIColor colorWithWhite:0.15 alpha:1];
                cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                
                break;
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone; // UITableViewCellSeparatorStyleNone;
        
        // color
        cell.contentView.backgroundColor = [UIColor clearColor]; //self.view.backgroundColor;
        cell.textLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor]; // self.view.backgroundColor;


        return cell;
    
    }
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (includeOverview && indexPath.section == 0)
    {
        CGSize size = [stripHTML(overviewText) sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:NSLineBreakByWordWrapping];
       return size.height;
       
    }
    else
    {
        return 66;
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTrailDetail"])
    {
            [[segue destinationViewController] setDetailText:overviewText];
    }
    else if ([segue.identifier isEqualToString:@"showMap"])
    {
        [[segue destinationViewController] setDetailText:kMapText];
        
    }

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: NSLocalizedString(@"Back",@"Back")
                                   style: UIBarButtonItemStylePlain
                                   target: nil action: nil];
    [self.navigationItem setBackBarButtonItem: backButton];

    
}

#pragma mark - table view delegate
/*
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (includeOverview && indexPath.section == 0)
    {
        
    }
}
*/

#pragma mark - convenience methods




-(void) refresh
{
    [self performSelector:@selector(loadTrails) withObject:nil afterDelay:2.0];
}



#pragma mark - methods to handle connections

-(void)receiveTrailsResponse:(HTTPFetcher *)myFetcher
{
    NSString *htmlstr = [[NSString alloc] initWithData:[myFetcher data] encoding:NSUTF8StringEncoding];

    [trailsArray removeAllObjects];
    
    // get overview
    NSString *overviewRegex = @"(?s)<!\\[CDATA\\[([^\\[]*?)<table";
    //    NSArray *overviewCaptures = [self getCapturesFromRegex:overviewRegex fromString:htmlstr];
    NSArray *overviewCaptures = getCapturesFromRegex(overviewRegex, htmlstr);
    if (overviewCaptures.count > 0)
    {
        overviewText = [[overviewCaptures objectAtIndex:0] mutableCopy];
        includeOverview = YES;
        //        NSLog(@"Overview text: %@", overviewText);
    }
    else
    {
        includeOverview = NO;
    }
    
    
    
    
    NSError *error = NULL;
    NSRegularExpression *regexTrails2 = [NSRegularExpression
                                         regularExpressionWithPattern:@"(?s)<tr>\\s*?<td.*?>(.*?)</td>\\s*?<td.*?</td>\\s*?<td.*?</td>\\s*?<td.*?>(.*?)</td>\\s*?<td.*?>(.*?)</td>\\s*?</tr>"
                                         options:NSRegularExpressionCaseInsensitive
                                         error:&error];
    
    NSArray *trArray = [regexTrails2 matchesInString:htmlstr
                                             options:0 range:NSMakeRange(0, [htmlstr length])];
    
    NSMutableArray *tempTrails = [[NSMutableArray alloc] init];
    if ([trArray count] > 0 )
    {
        
        for (NSTextCheckingResult *trResult in trArray)
        {
            NSLog(@"raw trail = %@", [htmlstr substringWithRange:[trResult rangeAtIndex:3]]);
            NSString *unTrimmedName =
            stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:1]] );
            NSString *name = [unTrimmedName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",
                                  stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:3]] ), @"condition",
                                  stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:2]]) , @"date", nil];
            [tempTrails addObject:dict];
        }
    }
    else
    {
        [tempTrails addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Unable to retrieve trail conditions", @"name", @"", @"conditions", @"", @"date", nil]];
    }
    
    
    trailsArray = [tempTrails mutableCopy];
    NSLog(@"Got %lu trails", (unsigned long)trailsArray.count);
    for (NSDictionary *trail in trailsArray)
        NSLog(@"%@",[trail objectForKey:@"condition"]);
    
    lastUpdated =  [NSDate date];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        [self.refreshControl endRefreshing];
        NSString *updateText = [NSString stringWithFormat:@"Last updated %@\npull to refresh", timeSinceUpdate(lastUpdated)];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:updateText];
    }
    else
        self.navigationItem.leftBarButtonItem.enabled = YES;
    
    [self.tableView reloadData];

}

// - (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
// {
//     [receivedData setLength:0];
// }
//
// - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//     [receivedData appendData:data];
//}
//
// - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
//{
//    NSLog(@"Trails connection failed. %@, %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
//    {
//        [self.refreshControl endRefreshing];
//        NSString *updateText = [NSString stringWithFormat:@"pull to refresh"];
//        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:updateText];
//    }
//    else
//        self.navigationItem.leftBarButtonItem.enabled = YES;
// 
//}

 
 
 /*
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 
    NSLog(@"Trails connection finished");
    NSString *htmlstr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    [trails removeAllObjects];
     
     //NSLog(@"Trails raw HTML: %@",htmlstr);


// NSDictionary *trailNames = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 @"Warm-up", @"WARM-UP LOOP",
//                                 @"Tower", @"TOWER LOOP",
//                                 @"Coasters", @"ROLLER COASTERS",
//                                 @"Relay", @"RELAY START LOOP",
//                                 @"Relay", @"RELAY START",
//                                 @"White Bear Access", @"WHITE BEAR ACCESS",
//                                 @"Blue Loop", @"BLUE LOOP",
//                                 @"Outhouse", @"OUTHOUSE LOOP",
//                                 @"Comp Loop", @"COMP LOOP",
//                                 @"North Forty", @"NORTH FORTY",
//                                 @"Black Hole", @"BLACK HOLE",
//                                 @"White Bear", @"WHITE BEAR",
//                                 @"Moilanen", @"MOILANEN MEADOWS",
//                                 @"Classical", @"CLASSICAL ONLY",
//                                 @"Tommy Knocker", @"TOMMY KNOCKER (NEW)",
//                                 @"Black Funk",@"BLACK FUNK (NEW)",
//                                 @"White Cub", @"WHITE CUB",
//                                 @"South Tower",@"SOUTH TOWER (NEW)",
//                                 @"Green Dot", @"GREEN DOT",
//                                 @"Blackhawk", @"BLACKHAWK",
//                                 @"Chinook", @"CHINOOK",
//                                 nil];
 
     
    // get overview
    
    NSString *overviewRegex = @"(?s)<!\\[CDATA\\[([^\\[]*?)<table";
//    NSArray *overviewCaptures = [self getCapturesFromRegex:overviewRegex fromString:htmlstr];
    NSArray *overviewCaptures = getCapturesFromRegex(overviewRegex, htmlstr);
    if (overviewCaptures.count > 0)
    {
        overviewText = [[overviewCaptures objectAtIndex:0] mutableCopy];
        includeOverview = YES;
//        NSLog(@"Overview text: %@", overviewText);
    }
    else
    {
        includeOverview = NO;
    }
    
    
    
    
     NSError *error = NULL;
     NSRegularExpression *regexTrails2 = [NSRegularExpression
                                          regularExpressionWithPattern:@"(?s)<tr>\\s*?<td.*?>(.*?)</td>\\s*?<td.*?</td>\\s*?<td.*?</td>\\s*?<td.*?>(.*?)</td>\\s*?<td.*?>(.*?)</td>\\s*?</tr>"
                                          options:NSRegularExpressionCaseInsensitive
                                          error:&error];
    
     NSArray *trArray = [regexTrails2 matchesInString:htmlstr
                                              options:0 range:NSMakeRange(0, [htmlstr length])];
     
     NSMutableArray *tempTrails = [[NSMutableArray alloc] init];
     if ([trArray count] > 0 )
     {
         
         for (NSTextCheckingResult *trResult in trArray)
         {
             NSString *unTrimmedName =
             stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:1]] );
             NSString *name = [unTrimmedName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
             
             
             
             NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",
                                   stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:3]] ), @"condition",
                                   stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:2]]) , @"date", nil];
             [tempTrails addObject:dict];
         }
     }
     else
     {
         [tempTrails addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Unable to retrieve trail conditions", @"name", @"", @"conditions", @"", @"date", nil]];
     }
    

     trails = [tempTrails mutableCopy];
     NSLog(@"Got %d trails", trails.count);

     lastUpdated =  [NSDate date];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        [self.refreshControl endRefreshing];
        NSString *updateText = [NSString stringWithFormat:@"Last updated %@\npull to refresh", timeSinceUpdate(lastUpdated)];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:updateText];
    }
    else
        self.navigationItem.leftBarButtonItem.enabled = YES;

    [self.tableView reloadData];
    connection = nil;
    receivedData = nil;
}
*/



#pragma mark - View lifecycle

- (void) loadTrails
{
    NSLog(@"Refreshing trails");
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        [self.refreshControl beginRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"loading..."];
    }
    else
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
    }
    
    /*
    NSURL *url = [NSURL URLWithString:kTrailsXML];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (conn)
    {
        receivedData = [NSMutableData data];
        NSLog(@"Connection to Trails successful");
        
    }
    */
    
    HTTPFetcher *fetcher = [[HTTPFetcher alloc] initWithURLString:kTrailsXML
                                                        receiver:self
                                                            action:@selector(receiveTrailsResponse:)];
    [fetcher start];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"pull to refresh"];
        [self.refreshControl addTarget:self action:@selector(loadTrails)
                 forControlEvents:UIControlEventValueChanged];
        [self.refreshControl beginRefreshing];
    }
    else
    {
        UIBarButtonItem *but = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadTrails)];
        self.navigationItem.leftBarButtonItem = but;
    }

    // read table section info from json file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"trails" ofType:@"json"];
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    tableSections = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"sections"]];
    
    if (IS_IPAD)
    {
        // don't need maps for ipad, as they're displayed on another tab
        [tableSections removeLastObject];
    }
    
    [self.navigationItem setTitle:NSLocalizedString(@"Birch Hill Trails", nil)];
    
    trailsArray = [[NSMutableArray alloc] init];

    overviewText = [NSMutableString stringWithCapacity:1000];
    includeOverview = NO;
    

    lastUpdated = [NSDate distantPast];
    
//    [self loadTrails];  // do this in view will appear now
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    contrast = IS_IPAD ? NO : [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
//    self.view.backgroundColor =  contrast ? [UIColor blackColor] : GRAY_BACKGROUND;
    contrast = NO;
    self.view.backgroundColor = GRAY_BACKGROUND;
    
    [self.tableView reloadData];
    NSLog(@"Last trails refresh %.f secs ago", -[lastUpdated timeIntervalSinceNow]);
    if (-[lastUpdated timeIntervalSinceNow] >=  kTrailsRefreshInterval)
    {
        [self loadTrails];
    }
}




- (void)viewDidUnload
{
    receivedData = nil;
    tableSections = nil;
    trailsArray = nil;
    navBar = nil;
    loadingLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
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
