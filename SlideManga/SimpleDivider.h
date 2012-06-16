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
    float _ratio;
    NSUInteger _bytesPerPixel;
    unsigned char* _rawData;
    bool* _markData;
}

@end
