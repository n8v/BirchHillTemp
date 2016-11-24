//
//  ColorButton.h
//  Colors
//
//  Created by Gazolla on 31/08/12.
//  Copyright (c) 2012 Gazolla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ColorButton : UIButton
{
    UIColor *color;
}
@property (strong) NSString *hexColor;
@property (nonatomic, copy) NSString *colorName;
@property (nonatomic, readonly) UIColor *color;

@end
