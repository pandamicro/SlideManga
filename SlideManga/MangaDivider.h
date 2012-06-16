//
//  MangaDivider.h
//  SlideManga
//
//  Created by LING HUABIN on 26/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MangaDivider <NSObject>

- (NSArray*)divide:(UIImage*)img;
- (NSArray*)getROIs;

@property(nonatomic, retain) UIImage* resImage;
@property(nonatomic, retain) NSArray* blobs;

@end
