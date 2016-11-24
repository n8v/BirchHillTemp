//
//  SafariAlertView.m
//  BirchHillTemp
//
//  Created by Gary Holton on 15/01/2013.
//
//

#import "SafariAlertView.h"

@implementation SafariAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate request:(NSURLRequest *)request
{
    self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    if (self)
        _request = request;
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
