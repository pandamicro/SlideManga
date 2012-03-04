//
//  MangaPage.m
//  SlideManga
//
//  Created by LING HUABIN on 26/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import "MangaPage.h"
#import "ROIDescriptor.h"

@implementation MangaPage

@synthesize divider = _divider;

#pragma mark - Initialization

- (id)initWithUIImage:(UIImage*)img andDivider:(id<MangaDivider>)divider{
    self = [super init];
    if (self) {
        _divider = divider;
        _img = img;
        _regions = [_divider divide:_img];
        _curr = 0;
    }
    return self;
}
- (id)initWithImageNamed:(NSString*)name andDivider:(id<MangaDivider>)divider{
    self = [super init];
    if (self) {
        _divider = divider;
        _img = [UIImage imageNamed:name];
        _regions = [_divider divide:_img];
        _curr = 0;
    }
    return self;
}

#pragma mark - Process control
- (CGRect)nextStep{
    if(_curr < [_regions count]-1) _curr++;
    return [(ROIDescriptor*)[_regions objectAtIndex:_curr] getBoundingBox];
}
- (CGRect)prevStep{
    if(_curr > 0) _curr--;
    return [(ROIDescriptor*)[_regions objectAtIndex:_curr] getBoundingBox];
}
- (void)rollback{
    _curr = 0;
}

@end
