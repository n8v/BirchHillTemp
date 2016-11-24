//
//  MapViewController.h
//  BirchHillTemp
//
//  Created by Gary Holton on 21/01/2013.
//
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIImageView *mapImageView;
    IBOutlet UIButton *flipButton;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

-(IBAction)flip:(id)sender;

@end
