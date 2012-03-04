//
//  MangaPage.h
//  SlideManga
//
//  Created by LING HUABIN on 26/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MangaDivider.h"

@interface MangaPage : NSObject {
@private
    UIImage *_img;
    NSArray *_regions;
    int _curr;
}
@property(nonatomic, retain) id<MangaDivider> divider;

- (id)initWithUIImage:(UIImage*)img andDivider:(id<MangaDivider>)divider;
- (id)initWithImageNamed:(NSString*)name andDivider:(id<MangaDivider>)divider;

// Manga reading process control
- (CGRect)nextStep;
- (CGRect)prevStep;
- (void)rollback;

@end
