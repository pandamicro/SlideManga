//
//  DataViewController.h
//  SlideManga
//
//  Created by LING HUABIN on 22/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MangaPage.h"

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) UIImage *img;
@property (nonatomic, retain) MangaPage *page;

- (void)fitInScreen;

@end
