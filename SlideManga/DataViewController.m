//
//  DataViewController.m
//  SlideManga
//
//  Created by LING HUABIN on 22/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import "DataViewController.h"

@interface DataViewController(internal)

- (void)handleDoubleTap;

@end

@implementation DataViewController

@synthesize imgView = _imgView;
@synthesize img = _img;
@synthesize page = _page;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    _img = [_page nextStep];
    _imgView = [[UIImageView alloc] initWithImage:_img];
    [self fitInScreen];
    [self.view addSubview:_imgView];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _imgView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (void)fitInScreen {
    float rx = 320 / _img.size.width;
    float ry = 480 / _img.size.height;
    float r = (rx < ry) ? rx : ry;
    int iw = _img.size.width * r;
    int ih = _img.size.height * r;
    int ix = (320-iw)/2;
    int iy = (480-ih)/2;
    _imgView.frame = CGRectMake(ix, iy, iw, ih);
}


#pragma mark - Touch event handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *aTouch = [touches anyObject];
    if (aTouch.tapCount == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *theTouch = [touches anyObject];
    if (theTouch.tapCount == 1) {
        NSDictionary *touchLoc = [NSDictionary dictionaryWithObject:
                                  [NSValue valueWithCGPoint:[theTouch locationInView:_imgView]] forKey:@"location"];
        [self performSelector:@selector(handleSingleTap:) withObject:touchLoc afterDelay:0.3];
    }
    else if (theTouch.tapCount == 2) {
        [self handleDoubleTap];
    }
}

- (void)handleSingleTap:(NSDictionary *)touches {
    _img = [_page nextStep];
    [_imgView setImage:_img];
    [self fitInScreen];
}
- (void)handleDoubleTap {
    _img = [_page prevStep];
    [_imgView setImage:_img];
    [self fitInScreen];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    /* no state to clean up, so null implementation */
}

@end
