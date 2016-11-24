//
//  ForecastViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 14/01/2013.
//
//

#import <UIKit/UIKit.h>
#import "HTTPFetcher.h"
#import "Helpers.h"
#import "ForecastDetailViewController.h"

@class ForecastDetailViewController;

@interface ForecastViewController : UITableViewController 


@property (strong, nonatomic) ForecastDetailViewController *detailViewController;


- (void) receiveResponse:(HTTPFetcher *)myFetcher;


- (void) loadForecast ;

@end