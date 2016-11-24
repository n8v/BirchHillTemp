//
//  SecondViewController.m
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "TrailsViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "TrailDetailViewController.h"

#define kTrailsRefreshInterval 3600

#define kMapText @"<img src='trail_map.png' width='529' height='575'></body></html>"

@interface TrailsViewController ()
{
    NSMutableArray *tableData;
    NSMutableData *receivedData;
    BOOL includeOverview;
    NSMutableString *overviewText;
    BOOL contrast;

}

@end

@implementation TrailsViewController
@synthesize pullTableView;



#pragma mark - table view datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[tableData objectAtIndex:section] objectForKey:@"trails"] count];

}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[tableData objectAtIndex:section] objectForKey:@"section_name"];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableData count];
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
    NSLog(@"Cell %d - %d", indexPath.section, indexPath.row);
    if ([[[tableData objectAtIndex:indexPath.section] objectForKey:@"section_name"] isEqualToString:@"Overview"])
    {
            static NSString *CellIdentifier = @"OverviewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
            }
            
            
            // Configure the cell...
        cell.textLabel.text = stripHTML([[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectForKey:@"title"]);
        CGRect rect = cell.contentView.frame;
        cell.contentView.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width-40, rect.size.height);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.textLabel.numberOfLines =3;
        
        // color
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor blackColor];
        
        return  cell;
    }
    else if ([[[tableData objectAtIndex:indexPath.section] objectForKey:@"section_name"] isEqualToString:@"Maps"])
    {
        static NSString *CellIdentifier = @"MapCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        
        // Configure the cell...
        cell.textLabel.text = [[[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"title"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = nil;
        
        // color
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor blackColor];
        
        return  cell;
        
    }
    else
    {
        // regular cell
        static NSString *CellIdentifier = @"TrailCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
            UILabel *lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 40, 21)];
            lengthLabel.tag = 21;
            lengthLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor darkGrayColor];
            lengthLabel.backgroundColor = [UIColor clearColor];
            lengthLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:lengthLabel];
        
        }
        
        
        // Configure the cell...
        
        // find the section
        NSString *trailName = [[[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        NSString *trailTitle = [[[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        // length
        float myLength = [[[[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"length" ] floatValue];
        myLength = roundf( myLength / 100.0) / 10; // leave one decimal place
        [(UILabel *)[cell.contentView viewWithTag:21] setText:[NSString stringWithFormat:@"%0.1f k", myLength] ];
        [(UILabel *)[cell.contentView viewWithTag:21] setTextColor:contrast ? [UIColor whiteColor] : [UIColor darkGrayColor]];
        
        // difficulty graphic
        NSString *difficulty = [[[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectAtIndex:indexPath.row] objectForKey:@"difficulty"];
        int diffIndex = [[NSArray arrayWithObjects:@"EASY", @"MORE DIFFICULT", @"DIFFICULT",  @"MOST DIFFICULT", @"VERY DIFFICULT", @"",nil]
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
        
        NSString *myDateString = [[[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectAtIndex:indexPath.row ] objectForKey:@"date"];
        NSString *myCondition = [[[[tableData objectAtIndex:indexPath.section] objectForKey:@"trails"] objectAtIndex:indexPath.row ] objectForKey:@"condition"];
//        NSArray *captures = getCapturesFromRegex(@"([0-9]{1,2}/[0-9]{1,2})/[0-9][0-9]", myDateString);
//        NSString *dateLabel = (captures.count > 0) ? [captures objectAtIndex:0] : [trail objectForKey:@"date"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", myCondition, myDateString];
        
        cell.detailTextLabel.textColor = contrast ? [UIColor colorWithWhite:0.85 alpha:1] : [UIColor colorWithWhite:0.15 alpha:1];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone; // UITableViewCellSeparatorStyleNone;
        
        // color
        cell.contentView.backgroundColor = [UIColor clearColor]; //self.view.backgroundColor;
        cell.textLabel.textColor = contrast ? [UIColor whiteColor] : [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor]; // self.view.backgroundColor;


        return cell;
    
    }
    
    
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (includeOverview && indexPath.section == 0)
    {
        //CGSize size = [overviewText sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(280, 9999) lineBreakMode:UILineBreakModeWordWrap];
       //     return size.height;
        return 66;
    }
    else
    {
        return 66;
    }
}
*/

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
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
                                   style: UIBarButtonItemStyleBordered
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

NSString *stripHTML(NSString *html) {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<.*?>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) 
    {
        NSLog(@"Error stripping HTML");
        return html;
    }
    else
    {
        NSString *stripped = [regex stringByReplacingMatchesInString:html
                                               options:NSRegularExpressionCaseInsensitive
                                                 range:NSMakeRange(0, [html length])
                                          withTemplate:@""];
        NSString *reStripped = [stripped stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
        return [reStripped stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    }
}


- (void) loadTrails
{
        NSLog(@"Refreshing trails");
    
        NSURL *url = [NSURL URLWithString:kTrailsXML];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
       if (conn)
        {
            receivedData = [NSMutableData data];
            NSLog(@"Connection to Trails successful");
            self.pullTableView.pullTableIsRefreshing = YES;

        }
        
}


-(void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadTrails) withObject:nil afterDelay:2.0];
}

-(void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    self.pullTableView.pullTableIsLoadingMore = NO;
}

-(void) refresh
{
    [self performSelector:@selector(loadTrails) withObject:nil afterDelay:2.0];
}



#pragma mark - methods to handle connections


 
 - (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
 {
     [receivedData setLength:0];
 }
 
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
     [receivedData appendData:data];
}
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    NSLog(@"Trails connection failed. %@, %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    self.pullTableView.pullTableIsRefreshing = NO;
 
}
 
 
 
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 
    NSLog(@"Trails connection finished");
    NSString *htmlstr = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];

    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"trails" ofType:@"json"];
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
    NSMutableArray *tempData = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"sections"]];
    

    
     //NSLog(@"Trails raw HTML: %@",htmlstr);
/*
    NSDictionary *trailNames = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"Warm-up", @"WARM-UP LOOP",
                                 @"Tower", @"TOWER LOOP",
                                 @"Coasters", @"ROLLER COASTERS",
                                 @"Relay", @"RELAY START LOOP",
                                 @"Relay", @"RELAY START",
                                 @"White Bear Access", @"WHITE BEAR ACCESS",
                                 @"Blue Loop", @"BLUE LOOP",
                                 @"Outhouse", @"OUTHOUSE LOOP",
                                 @"Comp Loop", @"COMP LOOP",
                                 @"North Forty", @"NORTH FORTY",
                                 @"Black Hole", @"BLACK HOLE",
                                 @"White Bear", @"WHITE BEAR",
                                 @"Moilanen", @"MOILANEN MEADOWS",
                                 @"Classical", @"CLASSICAL ONLY",
                                 @"Tommy Knocker", @"TOMMY KNOCKER (NEW)",
                                 @"Black Funk",@"BLACK FUNK (NEW)",
                                 @"White Cub", @"WHITE CUB",
                                 @"South Tower",@"SOUTH TOWER (NEW)",
                                 @"Green Dot", @"GREEN DOT",
                                 @"Blackhawk", @"BLACKHAWK",
                                 @"Chinook", @"CHINOOK",
                                 nil];
*/     
    // get overview
    
    NSString *overviewRegex = @"(?s)<!\\[CDATA\\[([^\\[]*?)<table";
//    NSArray *overviewCaptures = [self getCapturesFromRegex:overviewRegex fromString:htmlstr];
    NSArray *overviewCaptures = getCapturesFromRegex(overviewRegex, htmlstr);
    if (overviewCaptures.count > 0)
    {
        NSArray *overviewArray = [[overviewCaptures objectAtIndex:0] mutableCopy];
        // check to see if tableData already has key for Overview
            // insert new dict object at index 0
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"Overview", @"section_name", overviewArray, @"trails", nil];
            [tempData insertObject:dict atIndex:0];
     }
        
        
       
    
    
    
     //NSError *error = NULL;
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
             // create the dictionary
             NSString *unTrimmedName = stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:1]] );
             NSString *currentTrailName = [unTrimmedName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
             // now figure out where it goes
             for (NSMutableDictionary *mySection in tempData)
             {
                 for (int i=0; i < [[mySection objectForKey:@"trails"] count]; i++)
                 {
                     if ([[trail objectForKey:@"name"] isEqualToString:currentTrailName])
                     {
                         // found trail, update it
                         NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:currentTrailName,@"name",
                                               stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:3]] ), @"condition",
                                               stripHTML( [htmlstr substringWithRange:[trResult rangeAtIndex:2]]) , @"date",
                                               [trail objectForKey:@"title"], @"title",
                                               nil];
                         [[mySection objectForKey:@"trails"] objectAtIndex:i] = [dict mutableCopy]
                         break;
                         
                     }
                 }
             }
         
         }
     }
     else
     {
         //[tempTrails addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Unable to retrieve trail conditions", @"name", @"", @"conditions", @"", @"date", nil]];
     }
    

   
     self.pullTableView.pullLastRefreshDate = [NSDate date];
     self.pullTableView.pullTableIsRefreshing = NO;
     [self.tableView reloadData];
    connection = nil;
    receivedData = nil;
}




#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
//    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"pull me"];
//    [refreshControl addTarget:self action:@selector(loadTrails)
//             forControlEvents:UIControlEventValueChanged];
//    self.refreshControl = refreshControl;
    
    // read table section info from json file
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"trails" ofType:@"json"];
    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSError *error;
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    tableData = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"sections"]];
    
    
    
    [self.navigationItem setTitle:NSLocalizedString(@"Birch Hill Trails", nil)];
    

    overviewText = [NSMutableString stringWithCapacity:1000];
    includeOverview = NO;
    
    
    
    
//    [self loadTrails];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    contrast = [[NSUserDefaults standardUserDefaults] boolForKey:kPrefContrast];
    
    if (contrast)
    {
        self.pullTableView.pullArrowImage = [UIImage imageNamed:@"whiteArrow"];
        self.pullTableView.pullBackgroundColor = [UIColor blackColor];
        self.pullTableView.pullTextColor = [UIColor lightTextColor];
        self.view.backgroundColor = [UIColor blackColor];
    }
    else
    {
        self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
        self.pullTableView.pullBackgroundColor = GRAY_BACKGROUND; // [UIColor whiteColor];
        self.pullTableView.pullTextColor = [UIColor darkTextColor];
        self.view.backgroundColor = GRAY_BACKGROUND; // [UIColor whiteColor];
    }
    
    
    [self.tableView reloadData];
    
    NSLog(@"Last refresh %.f secs ago", -[self.pullTableView.pullLastRefreshDate timeIntervalSinceNow]);
    if (-[self.pullTableView.pullLastRefreshDate timeIntervalSinceNow] <  kTrailsRefreshInterval)
        [self loadTrails];
    
}




- (void)viewDidUnload
{
    receivedData = nil;
    tableData = nil;
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



@end
