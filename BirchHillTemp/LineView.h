//
//  CustomView.h
//
//  Creates lines for the main temperature display screen
//
//  Created by Gary Holton on 13/01/2013.
//  Copyright (c) 2013 Gary Holton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineView : UIView
{
    UIColor *lineColor;
}

@property (nonatomic, strong) UIColor *lineColor;

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint,
                   CGColorRef color);
void drawHorizontalLine(CGContextRef context, double y, CGColorRef color);
void drawVerticalLine(CGContextRef context, double x, double y, double height, CGColorRef color);

- (id)initWithFrame:(CGRect)frame andColor:(UIColor *)color;


@end
