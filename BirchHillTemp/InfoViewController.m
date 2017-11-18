//
//  InfoViewController.m
//  BirchHillTemp
//
//  Created by Gary Holton on 1/13/12.
//  Copyright (c) 2012 University of Alaska Fairbanks. All rights reserved.
//

#import "InfoViewController.h"
#import "GzColors.h"

#define DONATE_FOOTER @"Please consider joining the Nordic Ski Club of Fairbanks and making a donation to the trails fund."

#define DATA_SOURCES @"Birch Hill Ski Area temperature, trail conditions, webcam, and news provided by the Nordic Ski Club of Fairbanks. Fairbanks International Airport temperature provided by the National Weather Service. University of Alaska Fairbanks West Ridge temperature provided by the Alaska Climate Research Center. Goldstream temperature courtesy Goldstream Sports."


@interface InfoViewController()
{
    NSMutableArray *tableData;
    NSArray *settingsKeys;
}

@end

@implementation InfoViewController
@synthesize popoverController;
    
static NSString *JoinNSCFAlertTitle = @"Join NSCF";
static NSString *JoinNSCFAlertMsg = @"Proceed to the Nordic Ski Club Fairbanks online membership and donation system?";
static NSString *RateAppAlertTitle = @"Rate %@";
static NSString *RateAppAlertMsg = @"Open the App Store and submit a review of %@?";



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)done:(id)sender
{
    NSLog(@"INfo VC defaults changed: %@", self.defaultsChanged ? @"YES" : @"NO");
    [self.delegate infoViewControllerDidFinish:self];
}


-(IBAction)donate:(id)sender
{
    // open donation page
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedString(JoinNSCFAlertTitle,nil)
						  message:NSLocalizedString(JoinNSCFAlertMsg, nil)
						  delegate:self 
						  cancelButtonTitle:NSLocalizedString(@"Later", nil)
						  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [alert setTag:1];
	[alert show];
}

-(void)showDataSources
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedString(@"Data Sources",nil)
						  message:NSLocalizedString(DATA_SOURCES, nil)
						  delegate:self
						  cancelButtonTitle:NSLocalizedString(@"OK", nil)
						  otherButtonTitles: nil];
    [alert setTag:3];
	[alert show];
    
}

-(void)resetColors
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:NSLocalizedString(@"Reset Colos",nil)
						  message:@"Reset to default color scheme?"
						  delegate:self
						  cancelButtonTitle:NSLocalizedString(@"No", nil)
						  otherButtonTitles: NSLocalizedString(@"Yes", nil), nil];
    [alert setTag:4];
	[alert show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kNSCFDonationPage]];
   }
    else if (alertView.tag == 2)
    {
        if (buttonIndex == 1)
        {
            [Appirater rateApp];
        }
    }
    else if (alertView.tag == 4 && buttonIndex == 1)
    {
        // reset colors to defaults
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
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
        [prefs synchronize];
        
        [self getCurrentColors];
        [settingsTableView reloadData];
        
        
        
    }

}
-(IBAction)rateNow:(id)sender
{
    NSString *appTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	UIAlertView *rateAlert = [[UIAlertView alloc]
						  initWithTitle: [NSString stringWithFormat:NSLocalizedString(RateAppAlertTitle, nil), appTitle]
                              message: [NSString stringWithFormat:NSLocalizedString(RateAppAlertMsg, nil) , appTitle]
						  delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Later", nil)
						  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    [rateAlert setTag:2];
	[rateAlert show];

}

-(void) getCurrentColors
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _bubbleColor = [UIColor colorWithRed:[prefs floatForKey:@"Bubble_Red"] green:[prefs floatForKey:@"Bubble_Green"] blue:[prefs floatForKey:@"Bubble_Blue"] alpha:[prefs floatForKey:@"Bubble_Alpha"]];
    _bubbleTextColor = [UIColor colorWithRed:[prefs floatForKey:@"Text_Red"] green:[prefs floatForKey:@"Text_Green"] blue:[prefs floatForKey:@"Text_Blue"] alpha:[prefs floatForKey:@"Text_Alpha"]];
    _backgroundColor = [UIColor colorWithRed:[prefs floatForKey:@"Background_Red"] green:[prefs floatForKey:@"Background_Green"] blue:[prefs floatForKey:@"Background_Blue"] alpha:[prefs floatForKey:@"Background_Alpha"]];

}
#pragma mark - View lifecycle

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // NSLog(@"INfo view will appear");
    
    
    if (IS_IPAD)
    {
        [self getCurrentColors];
        [settingsTableView reloadData];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.defaultsChanged = NO;
    
    settingsKeys = [NSArray arrayWithObjects:kPrefUnits, kPrefChill, kPrefContrast, kPrefIcon, nil];
    
    navBar.topItem.title = NSLocalizedString(navBar.topItem.title, @"About");
    
    
    
    tableData = [[NSMutableArray alloc] init];
    if (IS_IPAD)
    {
        [tableData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Settings", @"header",
                              @"", @"footer",
                              [NSArray arrayWithObjects:@"Use Celsius", @"Bubble Color", @"Text Color",  @"Background Color", @"Reset Colors", nil], @"rows",
                              [NSArray arrayWithObjects:@"CellSwitch", @"CellColor", @"CellColor", @"CellColor", @"CellDisclosure", nil], @"cellIdentifiers",
                              nil]];
    }
    else
    {
        [tableData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Settings", @"header",
                              @"", @"footer",
                              [NSArray arrayWithObjects:@"Use Celsius", @"Show Wind Chill", nil], @"rows",
                              [NSArray arrayWithObjects:@"CellSwitch", @"CellSwitch", nil], @"cellIdentifiers",
                              nil]];
    }
    
    [tableData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Support the Nordic Ski Club", @"header",
                          DONATE_FOOTER, @"footer",
                          [NSArray arrayWithObjects:@"Donate", nil], @"rows",
                          [NSArray arrayWithObjects:@"CellDonate", nil], @"cellIdentifiers",
                          nil]];

    NSDate *year = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy"];
    NSString *yearString = [df stringFromDate:year];
    NSString *footerString = [NSString stringWithFormat:@"Copyright © 2011-%@  %@",yearString, kContactEmail];
    [tableData addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"App Information", @"header",
                          footerString, @"footer",
                          [NSArray arrayWithObjects:@"Data Sources", @"Rate This App", @"Version", nil], @"rows",
                          [NSArray arrayWithObjects:@"CellDisclosure", @"CellDisclosure", @"Cell", nil], @"cellIdentifiers",
                          nil]];

    
    
}

#pragma mark - table view

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableData count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[tableData objectAtIndex:section] objectForKey:@"rows"] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[tableData objectAtIndex:section] objectForKey:@"header"];
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [[tableData objectAtIndex:section] objectForKey:@"footer"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [[[tableData objectAtIndex:[indexPath section] ] objectForKey:@"cellIdentifiers"] objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

   
    if ([CellIdentifier isEqualToString:@"CellSwitch"])
    {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchView.tag = indexPath.row;
        switchView.on = [[NSUserDefaults standardUserDefaults] boolForKey:[settingsKeys objectAtIndex:indexPath.row]];
        [switchView addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];

        cell.accessoryView = switchView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = [[[tableData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
        return cell;
    }
    else if ([CellIdentifier isEqualToString:@"CellColor"])
    {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
//        UIButton *colorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        ColorButton *colorButton = [ColorButton buttonWithType:UIButtonTypeCustom];
        colorButton.frame = CGRectMake(0, 0, 35, 35);
        NSString *title = [[[tableData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
        if ([title isEqualToString:@"Bubble Color"])
            colorButton.backgroundColor = _bubbleColor;
        else if ([title isEqualToString:@"Text Color"])
            colorButton.backgroundColor = _bubbleTextColor;
        else
            colorButton.backgroundColor = _backgroundColor;
        colorButton.layer.cornerRadius = 4;
        colorButton.layer.borderColor = [UIColor blackColor].CGColor;
        colorButton.layer.borderWidth = 1.0f;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = colorButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[ [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.45] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1]  CGColor], nil];
        [colorButton.layer insertSublayer:gradient atIndex:0];
        if ([title isEqualToString:@"Bubble Color"])
            [colorButton addTarget:self action:@selector(showBubbleColorPicker:) forControlEvents:UIControlEventTouchUpInside];
        else if ([title isEqualToString:@"Text Color"])
            [colorButton addTarget:self action:@selector(showTextColorPicker:) forControlEvents:UIControlEventTouchUpInside];
        else
            [colorButton addTarget:self action:@selector(showBackgroundColorPicker:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        cell.accessoryView = colorButton;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.detailTextLabel.text = colorButton.colorName;
        cell.textLabel.text = [[[tableData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
        return cell;

    }
    else if ([CellIdentifier isEqualToString:@"CellDonate"])
    {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = [[[tableData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];

        return cell;
    }
    else if ( [CellIdentifier isEqualToString:@"CellDisclosure"])
    {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.detailTextLabel.text = @"";
        cell.textLabel.text = [[[tableData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
        
        return cell;
        
    }
    else if ( [CellIdentifier isEqualToString:@"Cell"])
    {
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
        }

        cell.accessoryView = nil;
        cell.accessoryType =  UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        cell.textLabel.text = [[[tableData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
        
        return cell;
    }
    
    return cell;
}

-(void)updateSwitchAtIndexPath:(id)sender
{
    UISwitch *mySwitch = (UISwitch *)sender;
    NSInteger myIndex = [mySwitch tag];
    NSLog(@"Switch: %ld", (long)myIndex );
    [[NSUserDefaults standardUserDefaults] setBool:mySwitch.on forKey:[settingsKeys objectAtIndex:myIndex]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.defaultsChanged = YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [[[tableData objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row];
    NSString *cellType =[[[tableData objectAtIndex:indexPath.section] objectForKey:@"cellIdentifiers"] objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if ([cellType isEqualToString:@"CellDonate"])
        [self donate:self];
    else if ([title isEqualToString:@"Rate This App"])
        [self rateNow:self];
    else if ([title isEqualToString:@"Data Sources"])
        [self showDataSources];
    else if ([cellType isEqualToString:@"CellColor"])
    {
        _changeColor = title;
//        NSLog(@"CLicked table: change color = %@", _changeColor);
        UIView *but = [[tableView cellForRowAtIndexPath:indexPath] accessoryView];
        if ([title isEqualToString:@"Bubble Color"])
                [self showBubbleColorPicker:but];
        else if ([title isEqualToString:@"Text Color"])
              [self showTextColorPicker:but];
        else if ([title isEqualToString:@"Background Color"])
                [self showBackgroundColorPicker:but];
    }
    else if ([title isEqualToString:@"Reset Colors"])
    {
        [self resetColors];
        [tableView reloadData];
    }

}
#warning just wut is this popover bubble color picker stuff
#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}



-(void)showBubbleColorPicker:(id)sender
{
    _changeColor = @"Bubble Color";
    UIView *but =  sender;
    [self showColorPickerFromRect:[but convertRect:but.bounds toView:self.view] withColor:_bubbleColor];
    
}

-(void)showTextColorPicker:(id)sender
{
    _changeColor = @"Text Color";
    UIView *but =  sender;
    [self showColorPickerFromRect:[but convertRect:but.bounds toView:self.view] withColor:_bubbleTextColor];
    
}
-(void)showBackgroundColorPicker:(id)sender
{
    _changeColor = @"Background";
    UIView *but =  sender;
    [self showColorPickerFromRect:[but convertRect:but.bounds toView:self.view] withColor:_backgroundColor];

}

-(void)showColorPickerFromRect:(CGRect)rect withColor:(UIColor *)color
{
    if (!self.popoverController) {
		
		ColorViewController *cvc = [[ColorViewController alloc] initWithColor:color];
        cvc.delegate = self;
		self.popoverController = [[WEPopoverController alloc] initWithContentViewController:cvc];
		self.popoverController.delegate = self;
		//self.popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
		
		[self.popoverController presentPopoverFromRect:rect
                                                inView:self.view
                              permittedArrowDirections:(UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown)
                                              animated:YES];
        
	} else {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
	}
    
}

-(void) colorPopoverControllerDidSelectColor:(NSString *)hexColor
{
    
    UIColor *selectedColor = [GzColors colorFromHex:hexColor];
    const CGFloat *components = CGColorGetComponents(selectedColor.CGColor);
    
//    const CGFloat  *components = CGColorGetComponents(self.bubbleColor.CGColor);
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    //changeColor = @"Bubble Color";
    
    if ([_changeColor isEqualToString:@"Bubble Color"])
    {
        _bubbleColor = selectedColor;
    }
    else if ([_changeColor isEqualToString:@"Text Color"])
    {
        _bubbleTextColor = selectedColor;
    }
    else
    {
        _backgroundColor = selectedColor;
    }
    NSString *key =  [[_changeColor componentsSeparatedByString:@" "] objectAtIndex:0];
    NSLog(@"key: %@", key);
    
    [prefs setFloat:components[0]  forKey:[NSString stringWithFormat:@"%@_Red", key]];
    [prefs setFloat:components[1]  forKey:[NSString stringWithFormat:@"%@_Green", key]];
    [prefs setFloat:components[2]  forKey:[NSString stringWithFormat:@"%@_Blue", key]];
    [prefs setFloat:components[3]  forKey:[NSString stringWithFormat:@"%@_Alpha", key]];
    [prefs synchronize];
    NSLog(@"Selected components: %f, %f, %f", components[0], components[1], components[2]);
    [settingsTableView reloadData];
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
}

- (void)viewDidUnload
{
    navBar = nil;
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
