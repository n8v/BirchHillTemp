
//  MapViewController.m
//  BirchHillTemp
//
//  Created by Gary Holton on 21/01/2013.
//
//

#import "MapViewController.h"

@interface MapViewController ()
{
}
@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:_scrollView belowSubview:flipButton];
    [self.scrollView setDelegate:self];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trails-2013-1.png"]];
    mapImageView.contentScaleFactor = .5;
//    CGRect rect = self.scrollView.frame;
    [self.scrollView addSubview:mapImageView];
    self.scrollView.contentSize = mapImageView.frame.size;
    
    double minScale = MAX(self.scrollView.frame.size.width / mapImageView.frame.size.width, self.scrollView.frame.size.height / mapImageView.frame.size.height);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.zoomScale = minScale;
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:tap];
    
    
       
}

-(IBAction)flip:(id)sender
{
    UIImage *flippedImage;
    if (mapImageView.image == [UIImage imageNamed:@"trails-2013-1.png"])
        flippedImage = [UIImage imageNamed:@"trails-2013-2.png"];
    else
        flippedImage = [UIImage imageNamed:@"trails-2013-1.png"];
    
    [UIView transitionWithView:self.view
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        mapImageView.image = flippedImage;
                    } completion:NULL];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return mapImageView;
}

-(void)handleTap:(UIGestureRecognizer *)sender
{
    CGRect rect = [self zoomRectForScrollView:self.scrollView withScale:2 withCenter:[sender locationInView:self.scrollView]];
    [self.scrollView zoomToRect:rect animated:YES];
}


- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"View size: %f, %f", self.view.frame.size.width, self.view.frame.size.height);
    NSLog(@"Scrollview frame size: %f, %f", self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    NSLog(@"Scrollview content size: %f, %f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    self.scrollView.contentSize = mapImageView.frame.size;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return  UIInterfaceOrientationMaskAll;
    
}
- (BOOL) shouldAutorotate {
    return NO; //IS_IPAD;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return IS_IPAD ? YES : (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


@end


