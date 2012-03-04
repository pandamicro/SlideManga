//
//  SimpleDivider.h
//  SlideManga
//
//  Created by LING HUABIN on 28/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MangaDivider.h"

@interface SimpleDivider : NSObject<MangaDivider> {
@private
    NSUInteger _width;
    NSUInteger _height;
    NSUInteger _bytesPerPixel;
    unsigned char* _rawData;
    bool* _markData;
}

@property(nonatomic, retain) UIImage* resImage;

@end
