//
//  FirstViewController.h
//  First tab: main temperature displays
//
//  Created by Gary Holton on 11/21/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

//#import "NSURLConnectionWithTag.h"
#import "InfoViewController.h"
#import "LineView.h"
#import "RoundedView.h"

@interface FirstViewController : UIViewController <InfoViewControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate>
{
    UIBarButtonItem *unitsButton;
    
    IBOutlet UIImageView *warningImageView;
    IBOutlet UILabel *windUnits;
    
    IBOutlet UITextView *todayForecastTextView;
    IBOutlet UILabel *todayLabel;
    
    IBOutlet UIImageView *iconImageView;

    
    // info button
//    IBOutlet UIButton *infoButtonLight;
    IBOutlet UIButton *infoButtonDark;
    
    
    // rounded views
    
    IBOutlet UIView *currentTempView;
    IBOutlet UIView *nwsTempView;
    IBOutlet UIView *uafTempView;
    IBOutlet UIView *gsTempView;
    
    IBOutlet UIView *highTempView;
    IBOutlet UIView *lowTempView;
    IBOutlet UIView *humidityView;
    
    IBOutlet UIView *windCurrentView;
    IBOutlet UIView *windAverageView;
    IBOutlet UIView *windMaxView;
    
    IBOutlet UIView *Line3;
    
    IBOutlet UIView *chillView;
    IBOutlet UIView *sunriseView;
    IBOutlet UIView *camView;
    
    IBOutlet UIView *forecastView;
    
    RoundedView *currentTempRounded;
    RoundedView *uafTempRounded;
    RoundedView *nwsTempRounded;
    RoundedView *goldstreamRounded;
    RoundedView *lowTempRounded;
    RoundedView *highTempRounded;
    RoundedView *humidityRounded;
    RoundedView *windCurrentRounded;
    RoundedView *windAverageRounded;
    RoundedView *windMaxRounded;
    RoundedView *chillRounded;
    RoundedView *webCamContainer;
    RoundedView *climateRounded;
    
    RoundedView *forecastRounded;
    
    UIWebView *webCamView;
    UIActivityIndicatorView *activityIndicator;
    
    RoundedView *sunriseContainer;
    UILabel *sunriseLabel;
    UILabel *todayForecastLabel;
    
    UILabel *climateTextLabel;

}

@property (nonatomic, retain) UIColor *bubbleColor;
@property (nonatomic, retain) UIColor *bubbleTextColor;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, copy) NSMutableString *currentTempString;
@property (nonatomic, retain) NSString *sunriseTime;
@property (nonatomic, retain) NSString *sunsetTime;
@property (nonatomic, retain) NSString *lodTime;

-(IBAction)tappedRefresh:(id)sender;
-(IBAction)showInfo:(id)sender;
- (IBAction) changeUnits:(id)sender;

NSString *tempInCelsius(NSString *temp);
NSString *tempInFahrenheit(NSString *temp);
NSString *tempRounded(NSString *temp);
//NSString *timeTo24Hour(NSString *timeString);
NSString *windToKph(NSString *wind);
NSString *windToMps(NSString *wind);

- (void) loadTemps;
-(NSString *)getTempStringForKey:(NSString *)keyValue fromDictionary:(NSDictionary *)dictionary;


@property (nonatomic, weak) IBOutlet UINavigationItem *navBarItem;


@end
