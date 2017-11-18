//
//  Helpers.m
//  BirchHillTemp
//
//  Created by Gary Holton on 16/01/2013.
//
//

#import "Helpers.h"

@implementation Helpers

NSString *timeSinceUpdate(NSDate *update)
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSIntegerMax fromDate:update];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
    float secPastMidnight = [update timeIntervalSinceDate:midnight];
    if (secPastMidnight > 0)
    {
        return [NSDateFormatter localizedStringFromDate:update dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    else
    {
        if (-secPastMidnight < 3600*24)
        {
            return @"yesterday";
        }
        else
        {
            int days = floorf(-secPastMidnight/(3600*24));
            return [NSString stringWithFormat:@"%d days ago", days];
        }
    }
}

NSString *getFirstCaptureFromRegex(NSString *regexString, NSString *fromString)
{
    NSArray *captures = getCapturesFromRegex(regexString, fromString);
    if ([captures count]>0)
        return [captures objectAtIndex:0];
    else
        return @"";
}

NSArray *getCapturesFromRegex(NSString *regexString, NSString *fromString)
{
    
    // returns nil if no captures found
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


NSString *cleanText(NSString *someText)
{
    return    [[ someText componentsSeparatedByCharactersInSet:[NSCharacterSet controlCharacterSet] ]
     componentsJoinedByString:@"" ];
    
}

// moved from TrailsViewController 2014-04-10
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
        NSMutableString *stripped = [[regex stringByReplacingMatchesInString:html
                                                                     options:NSMatchingReportCompletion
                                                                       range:NSMakeRange(0, [html length])
                                                                withTemplate:@""] mutableCopy];
        stripped = [[stripped stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
        
        stripped = [[stripped stringByReplacingOccurrencesOfString:@"\n" withString:@""] mutableCopy];
        stripped = [[stripped stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"] mutableCopy];
        
        return stripped;
    }
}


@end
