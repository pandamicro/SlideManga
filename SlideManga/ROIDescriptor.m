//
//  ROIDescriptor.m
//  SlideManga
//
//  Created by LING HUABIN on 25/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import "ROIDescriptor.h"

@implementation ROIDescriptor

@synthesize convexHulls;

- (id)init{
    self = [super init];
    if (self) {
        convexHulls = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (id)initWithCapacity:(int)cap{
    self = [super init];
    if (self) {
        convexHulls = [[NSMutableArray alloc] initWithCapacity:cap];
    }
    return self;
}

- (void)appendContourPoint:(CGPoint)p{
    [convexHulls addObject:[NSValue valueWithCGPoint:p]];
}

- (CGRect)getBoundingBox{
    float minx = CGFLOAT_MAX, maxx = CGFLOAT_MIN, miny = CGFLOAT_MAX, maxy = CGFLOAT_MIN;
    for (NSValue *value in convexHulls) {
        CGPoint pt = [value CGPointValue];
        if(pt.x < minx) minx = pt.x;
        if(pt.x > maxx) maxx = pt.x;
        if(pt.y < miny) miny = pt.y;
        if(pt.y > maxy) maxy = pt.y;
    }
    return CGRectMake(minx,miny,maxx-minx,maxy-miny);
}

@end
