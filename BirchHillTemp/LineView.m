//
//  CustomView.m
//  
//
//  Created by Gary Holton on 13/01/2013.
//  Copyright (c) 2013 Gary Holton. All rights reserved.
//

#import "LineView.h"



@implementation LineView

@synthesize lineColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        lineColor = [UIColor blackColor];  // default to black
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        lineColor = color;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

 - (void)drawRect:(CGRect)rect
 {
     const int yOff=20;
     // Drawing code
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     drawHorizontalLine(context, 175+yOff, lineColor.CGColor);
     drawHorizontalLine(context, 278+yOff, lineColor.CGColor);
     drawHorizontalLine(context, 375+yOff, lineColor.CGColor);

     // following without Goldstream sport (2 outlets on second row)
     // drawVerticalLine(context, 160, 175, 103, lineColor.CGColor);

     // following with Goldstream sport (3 outlets on second row)
     drawVerticalLine(context, 109, 175+yOff, 103, lineColor.CGColor);
     drawVerticalLine(context, 216, 175+yOff, 103, lineColor.CGColor);

     
     drawVerticalLine(context, 109, 278+yOff, 97, lineColor.CGColor);
     drawVerticalLine(context, 216, 278+yOff, 97, lineColor.CGColor);
     
     if (IS_IPHONE_5)
     {
         drawVerticalLine(context, 109, 374+yOff, 86, lineColor.CGColor);
         drawVerticalLine(context, 216, 374+yOff, 86, lineColor.CGColor);
         drawHorizontalLine(context, 460+yOff, lineColor.CGColor);
     }
     
 }


 void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, CGColorRef color)
{
 
     CGContextSaveGState(context);
     CGContextSetLineCap(context, kCGLineCapSquare);
     CGContextSetStrokeColorWithColor(context, color);
     CGContextSetLineWidth(context, 1.0);
     CGContextMoveToPoint(context, startPoint.x + 0.5, startPoint.y + 0.5);
     CGContextAddLineToPoint(context, endPoint.x + 0.5, endPoint.y + 0.5);
     CGContextStrokePath(context);
     CGContextRestoreGState(context);
 
 }
 
 void drawHorizontalLine(CGContextRef context, double y, CGColorRef color)
 {
     double screenWidth = [[UIScreen mainScreen] bounds].size.width;
     CGPoint startAt = CGPointMake(0, y);
     CGPoint endAt = CGPointMake(screenWidth, y);
     draw1PxStroke(context, startAt, endAt, color);
 }

void drawVerticalLine(CGContextRef context, double x, double y, double height, CGColorRef color)
{
    CGPoint startAt = CGPointMake(x, y);
    CGPoint endAt = CGPointMake(x, y+height);
    draw1PxStroke(context, startAt, endAt, color);
}

@end
