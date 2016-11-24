//
//  ListViewController.h
//  tabbedApp
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPFetcher.h"
#import "DetailViewController.h"

@class DetailViewController;

@interface ListViewController : UITableViewController
{

}

- (void) receiveResponse:(HTTPFetcher *)myFetcher;

- (void) fetchEntries;

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

@protocol ListViewControllerDelegate
-(void)listViewController:(ListViewController *)lvc handleObject:(id)object;
@end
