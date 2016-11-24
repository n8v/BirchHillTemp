//
//  ColorButton.m
//  Colors
//
//  Created by Gazolla on 31/08/12.
//  Copyright (c) 2012 Gazolla. All rights reserved.
//

#import "ColorButton.h"


@implementation ColorButton
@synthesize hexColor;
@synthesize color;
@synthesize colorName;

-(UIColor *)color
{
    NSString *colorString = [[hexColor uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
    if ([colorString length] < 6)
        return [UIColor grayColor];
    
    if ([colorString hasPrefix:@"0X"])
        colorString = [colorString substringFromIndex:2];
    else if ([colorString hasPrefix:@"#"])
        colorString = [colorString substringFromIndex:1];
    else if ([colorString length] != 6)
        return  [UIColor grayColor];
    
    NSRange range;
    range.location = 2;
    range.length = 2;
    NSString *rString = [colorString substringWithRange:range];
    range.location += 2;
    NSString *gString = [colorString substringWithRange:range];
    range.location += 2;
    NSString *bString = [colorString substringWithRange:range];
    
    unsigned int red, green, blue;
    [[NSScanner scannerWithString:rString] scanHexInt:&red];
    [[NSScanner scannerWithString:gString] scanHexInt:&green];
    [[NSScanner scannerWithString:bString] scanHexInt:&blue];
    
    return [UIColor colorWithRed:((float) red / 255.0f)
                           green:((float) green / 255.0f)
                            blue:((float) blue / 255.0f)
                           alpha:1.0f];
}

@end
