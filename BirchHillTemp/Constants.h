//
//  Constants.h
//  BirchHillTemp
//
//  Created by Gary Holton on 11/19/11.
//  Copyright (c) 2011 University of Alaska Fairbanks. All rights reserved.
//

#ifndef BirchHillTemp_Constants_h
#define BirchHillTemp_Constants_h

// contact
#define kContactEmail @"gary.holton@gmail.com"

// fonts
#define kDefaultFontSize 16;

//  device verison
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568.0) < 1.0)
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < 1.0 )
//#define IS_IPHONE_5 ( IS_IPHONE && IS_WIDESCREEN )

// system version
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS_6 ([[[UIDevice currentDevice] systemVersion] compare:(@"6.0") options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS_7 ([[[UIDevice currentDevice] systemVersion] compare:(@"7.0") options:NSNumericSearch] != NSOrderedAscending)
// #define IS_IOS_8 ([[[UIDevice currentDevice] systemVersion] compare:(@"8.0") options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS_8 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)


// colors
#define GRAY_BACKGROUND [UIColor colorWithWhite:.97 alpha:1];

// UAF weather
// #define kUAFurl @"http://climate.gi.alaska.edu"
// #define kUAFurl @"http://akclimate.org/wxstation/files/text_summary.html"
#define kUAFurl @"http://akclimate.org/wview/index.html"


// URLs
#define kForecastZone @"http://forecast.weather.gov/MapClick.php?zoneid=AKZ222&TextType=1"
#define kAlertXML @"http://alerts.weather.gov/cap/wwaatmget.php?x=AKZ222&y=0"
#define kForecastIconURL @"http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgen&lat=64.8185&lon=-147.722&product=glance&product=glance&icons=icons&startTime=%@&endTime=%@"
#define kForecastWarning @"http://forecast.weather.gov/showsigwx.php?warnzone=AKZ222&warncounty=AKC090&firewxzone=AKZ222"
#define kWebCamURL @"http://www.nscfairbanks.org/gallery/camera.jpg"
#define kNWSxml @"http://www.weather.gov/xml/current_obs/PAFA.xml"
#define kForecastxml @"http://pafc.arh.noaa.gov/rss/rssget.php?zone=AKZ222"
#define kForecastText @"http://pafc.arh.noaa.gov/rss/fcst.php?zone=AKZ222"
#define kNWSurl @"http://weather.noaa.gov/weather/current/PAFA.html"
#define kNSCFurl @"http://www.nscfairbanks.org/weatherpage/wx.html"
#define kTrailsURL @"http://www.nscfairbanks.org/new/index.php?option=com_content&view=category&layout=blog&id=16&Itemid=100014"
#define kTrailsXML @"http://www.nscfairbanks.org/index.php?option=com_content&view=category&format=feed&type=rss&id=16"
#define kNSCFHomeUrl @"http://www.nscfairbanks.org"
#define kNSCFjson @"http://nscfairbanks.org/weatherpage/wap/index.wml"
#define kNSCFraw @"http://nscfairbanks.org/weatherpage/clientraw.txt"
#define kNSCFrawextra @"http://nscfairbanks.org/weatherpage/clientrawextra.txt"
#define kNSCFrawhour @"http://nscfairbanks.org/weatherpage/clientrawhour.txt"
#define kSkiRaceUrl @"http://www.skiraces.sportalaska.com"
#define kNSCFxml @"http://www.nscfairbanks.org/index.php?format=feed&type=rss"   // news feed
#define kNSCFDonationPage @"https://nscf.memberclicks.net/index.php?option=com_mc&view=mc&mcid=form_108585&test=1"

#define kGoldstreamSportsWeather @"http://goldstreamsports.com/weather/index.htm"

// custom alert message uploaded here
#define kCustomAlert @"http://nscfairbanks.org/weatherpage/wap/alert.json"

// keys for defaults
#define kFahrenheit @"Fahrenheit"
#define kCelsius @"Celsius"
#define KPrefRefreshInterval @"RefreshInterval"
#define kPrefContrast @"Contrast"
#define kPrefUnits  @"Units"
#define kPrefShowWebCam @"webCam"
#define kPrefChill @"Chill"
#define kPrefIcon @"Icon"
#define kPrefColor @"Color"

// default refresh intervals
#define kRefreshInterval 300
#define kForecastRefreshInterval 1 * 3600  // seconds
#define kWebCamRefreshInterval 5 * 60


// decimal places for rounding temps
#define kCelsiusDecimalPlaces 0

// units conversions
#define FAHRENHEIT_TO_CELSIUS(temp) (temp - 32.0) * 5.0/9.0
#define CELSIUS_TO_FAHRENHEIT(temp) temp*9.0/5.0 + 32

#define WINDCHILL_CELSIUS(temp,wind) 13.12 + 0.6215*temp -11.37*pow(wind,0.16) + 0.3965*temp*pow(wind,0.16)
#define WINDCHILL_FAHRENHEIT(temp,wind) 35.74 + 0.6215*temp -35.75*pow(wind,0.16) + 0.4275*temp*pow(wind,0.16)

#define KNOTS_TO_MPH(wind) wind*1.15078
#define KNOTS_TO_MPS(wind)  wind * 0.514444
#define MPH_TO_MPS(wind)  wind * 0.44704

#endif
