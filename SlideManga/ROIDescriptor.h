//
//  ROIDescriptor.h
//  SlideManga
//
//  Created by LING HUABIN on 25/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ROIDescriptor : NSObject

@property (nonatomic, copy) NSMutableArray *convexHulls;

- (id)initWithCapacity:(int)cap;
- (void)appendContourPoint:(CGPoint)p;
- (CGRect)getBoundingBox;

@end
