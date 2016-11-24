//
//  SafariAlertView.h
//  BirchHillTemp
//
//  Created by Gary Holton on 15/01/2013.
//
//

#import <UIKit/UIKit.h>

@interface SafariAlertView : UIAlertView
{
}
@property (nonatomic, copy) NSURLRequest *request;

-(id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate request:(NSURLRequest *)request;

@end
