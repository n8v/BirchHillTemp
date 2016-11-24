//
//  SettingsViewController.m
//  BirchHillTemp
//
//  Created by Gary Holton on 12/28/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import "SettingsViewController.h"

@implementation SettingsViewController
@synthesize tv;
@synthesize delegate = _delegate;

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
    selectedRow = -1;
}

-(void)viewWillAppear:(BOOL)animated
{
    selectedRow = -1;
    [tv reloadData];
    NSLog(@"SettingsViewController will appear");
    
}

-(IBAction)done:(id)sender
{
    // save defaults

    
    [self.delegate settingsViewControllerDidFinish:self];
    
}


-(void) dealloc
{
    NSLog(@"setting view controller dealloc");
    [tv release];
    //[defaults release];
    
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




#pragma mark - table view methods

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"";
            break;
        case 1:
            return @"About BirchHillTemp";
            break;
        default:
            return @"";
            break;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return @"If you like this App please consider joining the Nordic Ski Club of Fairbanks and donating to the Trail Grooming Fund.";
            break;
        default:
            return @"";
            break;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)myTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    
    UITableViewCell *cell = [myTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier:CellIdentifier] 
                autorelease];
    }
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (indexPath.section == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Temperature Units";
                cell.detailTextLabel.text = ( [defaults integerForKey:@"Units"] == 0 ? @"Fahrenheit" : @"Celsius" );
                
                break;
                
            case 1:
                cell.textLabel.text = @"Refresh Interval";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.f minutes", [defaults integerForKey:@"RefreshInterval"] / 60.0 ];
                
                break;
            default:
                // cell.textLabel.text = @"";
                break;
        }
    }
    else if (indexPath.section == 1)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Version";
                cell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
                break;
                
            case 1:
                cell.textLabel.text = @"Copyright";
                
                cell.detailTextLabel.text = @"2011 Marmot Media";
                
                break;
            case 2:
                cell.textLabel.text = @"Support";
                cell.detailTextLabel.text = @"gary.holton@gmail.com";
                break;
            default:
                // cell.textLabel.text = @"";
                break;
        }
    }
    else if (indexPath.section == 2)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
        cell.textLabel.text = @"Join NSCF!";
        cell.detailTextLabel.text = @"";
        
        
    }
    
    return cell;
}

#pragma mark - table view delegate methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSettingsDetail"])
    {
 
        // need to pass reference to appropriate settings -- and be able to get it back
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        
        switch (selectedRow) {
            case 0:
                [[segue destinationViewController] setCurSettingKey:@"Units"];
                
                NSLog(@"units string: %@", [defaults stringForKey:@"Units"]);
                NSLog(@"units integer %i", [defaults integerForKey:@"Units"]);
                
                [[segue destinationViewController] setCurSettingIndex:[defaults integerForKey:@"Units"]];
                break;
            case 1:
                [[segue destinationViewController] setCurSettingKey:@"RefreshInterval"];
                NSArray *defaultRefreshIntervals = [NSArray arrayWithObjects:@"60",@"120",@"300",@"600",@"1800", nil];
                [[segue destinationViewController] setCurSettingIndex:[defaultRefreshIntervals 
                                                                       indexOfObject:[NSString stringWithFormat:@"%i",
                                                                                      [defaults integerForKey:@"RefreshInterval"]]]];
                
                break;
            default:
                break;
        }
        
        NSLog(@"Prep segue: Key=%@, Index=%i",[[segue destinationViewController] curSettingKey],
              [[segue destinationViewController] curSettingIndex]);
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        selectedRow = indexPath.row;
        [self performSegueWithIdentifier:@"showSettingsDetail" sender:nil];
    }
    
    else if (indexPath.section == 2)
    {
        // donate
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Join NSCF"
                              message:@"Proceed to the Nordic Ski Club Fairbanks online membership and donation system?"
                              delegate:self 
                              cancelButtonTitle:@"Later"
                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSLog(@"Button index: %d\nButton title: %@", buttonIndex, [alertView buttonTitleAtIndex:buttonIndex]);
        if (buttonIndex == 1)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kNSCFDonationPage]];
}
        
        



@end
