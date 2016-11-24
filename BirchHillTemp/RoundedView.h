//
//  RoundedView.h
//
//  Created by Gary Holton on 21/01/2013.
//  Copyright (c) 2013 Gary Holton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class RoundedView;

@interface RoundedView : UIView
{
}

@property (nonatomic, copy) UILabel *mainText;
@property (nonatomic, copy) UILabel *headerText;
@property (nonatomic, copy) UILabel *footerText;
@property (nonatomic, copy) UILabel *unitsText;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) UIColor *color;


-(void)setImage:(UIImage *)img;
-(void)setTextColor:(UIColor *)color;
-(void)highContrast;
-(void)lowContrast;
-(void)fitSize;
-(void)startJiggling;
-(void)stopJiggling;

- (id)initWithFrame:(CGRect)frame andFontSize:(NSInteger)fontSize;
- (id)initWithFrame:(CGRect)frame andFontSize:(NSInteger)fontSize footer:(BOOL)hasFooter;
- (id)initWithFrame:(CGRect)frame andFontSize:(NSInteger)fontSize footer:(BOOL)hasFooter header:(BOOL)hasHeader;

-(void)startActivityIndicator;
-(void)stopActivityIndicator;

-(void)fadeIn;
-(void)fadeOut;
-(void)fadeInWithDuration:(NSTimeInterval)duration;
-(void)fadeOutWithDuration:(NSTimeInterval)duration;
-(void)setMainTextWithFade:(NSString *)text;
-(void)setFooterTextWithFade:(NSString *)text;

-(void)moveX:(float)x andY:(float)y;
-(void)moveX:(float)x;
-(void)moveY:(float)y;


@end
