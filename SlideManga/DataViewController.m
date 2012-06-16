//
//  DataViewController.m
//  SlideManga
//
//  Created by LING HUABIN on 22/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import "DataViewController.h"

@implementation DataViewController

@synthesize imgView = _imgView;
@synthesize img = _img;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    _imgView = [[UIImageView alloc] initWithImage:_img];
    _imgView.frame = CGRectMake(0, 0, 320, 480);
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

@end
