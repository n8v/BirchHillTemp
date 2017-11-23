//
//  RoundedView.m
//
//  Created by Gary Holton on 21/01/2013.
//  Copyright (c) 2013 Gary Holton. All rights reserved.
//

#import "RoundedView.h"

#define kHeaderInset 3
#define kHeaderHeight 21
#define kMainTextInset  25
#define kImageSize CGSizeMake(36,84)

#define TEXT_COLOR [UIColor colorWithWhite:.2 alpha:1]


//  minimum sizes on iPad
#define kMinWidth 50 //200
#define kMinHeight 50 //100

@interface RoundedView ()
{
    UIImageView *imageView;
    UIActivityIndicatorView *activityIndicator;
}
@end

@implementation RoundedView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame andFontSize:0 footer:YES header:YES];
}

- (id)initWithFrame:(CGRect)frame andFontSize:(NSInteger)fontSize
{
    return [self initWithFrame:frame andFontSize:fontSize footer:YES header:YES];
}
- (id)initWithFrame:(CGRect)frame andFontSize:(NSInteger)fontSize footer:(BOOL)hasFooter
{
    return [self initWithFrame:frame andFontSize:fontSize footer:YES header:YES];
}
- (id)initWithFrame:(CGRect)frame andFontSize:(NSInteger)fontSize footer:(BOOL)hasFooter header:(BOOL)hasHeader
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) &&  (frame.size.width < kMinWidth || frame.size.height < kMinHeight))
        {
            self.frame = CGRectMake(frame.origin.x, frame.origin.y, MAX(frame.size.width, kMinWidth), MAX(frame.size.height, kMinHeight));
        }
        
        
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        
        self.autoresizesSubviews = YES;
        
        float vHeight = self.bounds.size.height;
        float vWidth = self.bounds.size.width;
        
        
        
        CGRect headerRect = CGRectMake(0, kHeaderInset, self.bounds.size.width, kHeaderHeight);
        _headerText = [[UILabel alloc] initWithFrame:headerRect];
        _headerText.backgroundColor = [UIColor clearColor];
        _headerText.textColor = TEXT_COLOR; //[UIColor blackColor];
        _headerText.textAlignment = NSTextAlignmentCenter;
        _headerText.font = [UIFont systemFontOfSize:16];
        _headerText.tag = 11;
        [self addSubview:_headerText];
        
        
        CGRect footerRect = CGRectMake(0, vHeight - kHeaderInset - kHeaderHeight, self.bounds.size.width, kHeaderHeight);
        _footerText = [[UILabel alloc] initWithFrame:footerRect];
        _footerText.backgroundColor = [UIColor clearColor];
        _footerText.textColor = TEXT_COLOR;  // [UIColor blackColor];
        _footerText.textAlignment = NSTextAlignmentCenter;
        _footerText.font = [UIFont systemFontOfSize:16];
        _footerText.tag = 11;
        [self addSubview:_footerText];
        
        
        CGRect imageRect = CGRectMake(10, (vHeight -kImageSize.height)/2, kImageSize.width, kImageSize.height);
        imageView = [[UIImageView alloc] initWithFrame:imageRect];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        
        
        CGRect unitsRect = CGRectMake(vWidth-20, (vHeight-58)/2, 12, 58);
        _unitsText = [[UILabel alloc] initWithFrame:unitsRect];
        _unitsText.backgroundColor = [UIColor clearColor];
        _unitsText.textColor = [UIColor blackColor];
        _unitsText.font = [UIFont systemFontOfSize:12];
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0)
            _unitsText.minimumScaleFactor = 0.1;
        else
            _unitsText.minimumFontSize = 6;
        _unitsText.adjustsFontSizeToFitWidth = YES;
        _unitsText.numberOfLines = 3;
        _unitsText.textAlignment = NSTextAlignmentCenter;
        _unitsText.tag = 11;
        [self addSubview:_unitsText];
        
        
        CGRect activityRect = CGRectMake((vWidth - 20)/2, (vHeight-20)/2, 20, 20);
        activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:activityRect];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        [self addSubview:activityIndicator];
        
        
        CGRect mainRect = CGRectMake(0, (hasHeader ? kMainTextInset : 0), self.bounds.size.width, vHeight-kMainTextInset * (hasFooter ? 1 : 0) - kMainTextInset * (hasHeader ? 1 : 0));
        _mainText = [[UILabel alloc] initWithFrame:mainRect];
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0)
            _unitsText.minimumScaleFactor = 0.1;
        else
            _unitsText.minimumFontSize = 6;
        _mainText.numberOfLines = 1;
        _mainText.backgroundColor = [UIColor clearColor];
        _mainText.textColor = [UIColor blackColor];
        _mainText.textAlignment = NSTextAlignmentCenter;
        _mainText.clipsToBounds = NO;
        _mainText.tag = 11;
        [self addSubview:_mainText];
        if (fontSize > 0)
        {
            _mainText.font = [UIFont systemFontOfSize:fontSize];
        }
        else
        {
            CGSize size = [@"XXX" sizeWithFont:[UIFont systemFontOfSize:12.0]];
//            NSLog(@"Size: %f, %f", size.width, size.height);
            _mainText.font = [UIFont systemFontOfSize:(_mainText.frame.size.height) * 12.0 / size.height *1.2];
        }

        
        
        self.layer.shadowOffset = CGSizeMake(5, 5);
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
        self.clipsToBounds = NO;
        
        
    }
    return self;
}

-(void)setImage:(UIImage *)img
{
    imageView.image = img;
}

-(void)setTextColor:(UIColor *)color
{
    self.mainText.textColor = color;
    self.headerText.textColor = color;
    self.footerText.textColor = color;
    self.unitsText.textColor = color;
}

-(void)highContrast
{
    [self setTextColor:[UIColor whiteColor]];;
}

-(void)lowContrast
{
    [self setTextColor:[UIColor colorWithWhite:.9 alpha:1]];
}

-(void)startActivityIndicator
{
    [activityIndicator startAnimating];
}

-(void)stopActivityIndicator
{
    [activityIndicator stopAnimating];
}

-(void)setMainTextWithFade:(NSString *)text
{
    [UIView animateWithDuration:0.25 animations:^(void){
        self.mainText.alpha =0;
    } completion:^(BOOL finished){
        self.mainText.text = text;
        [UIView animateWithDuration:0.5 animations:^(void){self.mainText.alpha = 1.0;}];
    }
     ];
    
}

-(void)setFooterTextWithFade:(NSString *)text
{
    [UIView animateWithDuration:0.25 animations:^(void){
        self.footerText.alpha =0;
    } completion:^(BOOL finished){
        self.footerText.text = text;
        [UIView animateWithDuration:0.5 animations:^(void){self.footerText.alpha = 1.0;}];
    }
     ];
    
}

-(void)fadeInWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^(void){
        self.mainText.alpha =1;
        self.footerText.alpha = 1;
    }
     ];
}
-(void)fadeOutWithDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^(void){
        self.mainText.alpha = 0;
        self.footerText.alpha = 0;
    }
     ];
}

-(void)fadeIn
{
    [self fadeInWithDuration:1.0];
}
-(void)fadeOut
{
    [self fadeOutWithDuration:1.0];
}

-(void)fitSize
{
    NSString *myText = [self.mainText.text isEqualToString:@""] ? @"XXX" : self.mainText.text;
    CGSize size = [myText sizeWithFont:[UIFont systemFontOfSize:12.0]];
    NSLog(@"Size: %f, %f", size.width, size.height);
    self.mainText.font = [UIFont systemFontOfSize:(self.mainText.frame.size.height) * 12.0 / size.height *1.2];
}

-(void)moveX:(float)x andY:(float)y
{
    self.center = CGPointMake(self.center.x + x, self.center.y + y);
}
-(void)moveX:(float)x
{
    [self moveX:x andY:0];
}
-(void)moveY:(float)y
{
    [self moveX:0 andY:y];
}



#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 1.0

-(void)startJiggling
{
    NSInteger randomInt = arc4random()%500;
    float r = (randomInt/500.0)+0.5;

    CGAffineTransform leftWobble = CGAffineTransformMakeRotation(degreesToRadians( (kAnimationRotateDeg * -1.0) - r ));
    CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg + r ));

    self.transform = leftWobble;  // starting point

    [[self layer] setAnchorPoint:CGPointMake(0.5, 0.5)];

    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
                         [UIView setAnimationRepeatCount:NSNotFound];
                         self.transform = rightWobble; }
                     completion:nil];
}

-(void)stopJiggling
{
    [self.layer removeAllAnimations];
    self.transform = CGAffineTransformIdentity;
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
