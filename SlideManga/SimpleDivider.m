//
//  SimpleDivider.m
//  SlideManga
//
//  Created by LING HUABIN on 28/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import "SimpleDivider.h"

#define loop
#define TEST

enum Relation {
    LEFT = 1,
    CONNECT = 2,
    RIGHT = 3
    };

@class Blob;

@interface Profil : NSObject

@property (nonatomic, assign) int ox;
@property (nonatomic, assign) int oy;
@property (nonatomic, assign) int width;
@property (nonatomic, retain) Blob* pblob;

- (id)initWithPointOx:(int)x Oy:(int)y andWidth:(int)width;

@end

@implementation Profil
@synthesize ox=_ox, oy=_oy, width=_width, pblob;

- (id)initWithPointOx:(int)x Oy:(int)y andWidth:(int)width {
    self = [super init];
    if (self) {
        _ox = x;
        _oy = y;
        _width = width;
        pblob = nil;
    }
    return self;
}
@end


@interface Blob : NSObject {
@private
    NSMutableArray* _profils;
    BOOL            _boxInvalid;
}

@property BOOL connected;

- (id)initWithProfil:(Profil*)profil;

- (void)addProfil:(Profil*)profil;
- (NSArray*)profils;

- (int)checkConnect:(Profil*)profil;
- (void)combien:(Profil*)profil;

- (CGRect)getBoundingBox;
- (NSInteger)boundingBoxSurface;

NSInteger profilSort(Profil* p1, Profil* p2, void *context);

@end

@implementation Blob

@synthesize connected = _connected;

NSInteger profilSort(Profil* p1, Profil* p2, void *context)
{
    int x1 = p1.ox, y1 = p1.oy;
    int x2 = p2.ox, y2 = p2.oy;
    if (y1 < y2)
        return NSOrderedAscending;
    else if (y1 > y2)
        return NSOrderedDescending;
    else {
        if (x1 < x2) return NSOrderedAscending;
        else if(x1 > x2) return NSOrderedDescending;
        else return NSOrderedSame;
    }
}

- (id)initWithProfil:(Profil*)profil {
    self = [super init];
    if (self) {
        _boxInvalid = true;
        _profils = [NSMutableArray arrayWithCapacity:300];
        [self addProfil:profil];
    }
    return self;
}

- (void)addProfil:(Profil*)profil {
    _connected = true;
    _boxInvalid = true;
    // Register the blob owner in profil
    profil.pblob = self;
    for (int i = 0; i < [_profils count]; ++i) {
        if (profil.oy < [[_profils objectAtIndex:i] oy]) {
            [_profils insertObject:profil atIndex:i];
            return;
        }
    }
    [_profils addObject:profil];
}
- (NSArray*)profils {
    return [NSArray arrayWithArray:_profils];
    //return [_profils sortedArrayUsingFunction:profilSort context:NULL];
}

- (int)checkConnect:(Profil*)profil {
    int res = RIGHT;
    //NSArray *sorted = [_profils sortedArrayUsingFunction:profilSort context:NULL];
    int size = [_profils count];
    if (size <= 0) return LEFT;
    // Compare the last profils in this blob
    for (int i = size-1; i>=0; --i) {
        Profil* curr = [_profils objectAtIndex:i];
        if (abs(curr.oy-profil.oy) > 1) break;
        // Connect
        if (curr.ox <= profil.ox+profil.width && profil.ox <= curr.ox+curr.width) {
            return CONNECT;
        }
        else if (profil.ox > curr.ox+curr.width) {
            res = LEFT;
        }
    }
    return res;
}

- (void)combien:(Profil*)profil {
    // Profil individuel
    if(profil.pblob == nil) {
        [self addProfil:profil];
    }
    // Profil in a blob, combien with the whole blob (in order)
    else {
        _connected = true;
        _boxInvalid = true;
        NSArray* tars = [profil.pblob profils];
        Profil* tar = [tars objectAtIndex:0];
        int i,j;
        int tarSize = [tars count];
        for (i = 0, j = 0; i < [_profils count]; ++i) {
            int curry = [[_profils objectAtIndex:i] oy];
            while (tar.oy < curry) {
                tar.pblob = self;
                [_profils insertObject:tar atIndex:i];
                ++j;
                if(j < tarSize) tar = [tars objectAtIndex:j];
                else return;
            }
        }
        
        for (; j < tarSize; ++j) {
            tar = [tars objectAtIndex:j];
            tar.pblob = self;
            [_profils addObject:tar];
        }
    }
}

- (CGRect)getBoundingBox {
    CGRect box = CGRectZero;
    if (_boxInvalid) {
        NSInteger minx = NSIntegerMax, maxx = NSIntegerMin, miny = NSIntegerMax, maxy = NSIntegerMin;
        for (Profil* p in _profils) {
            if (p.ox < minx) minx = p.ox;
            if (p.oy < miny) miny = p.oy;
            if (p.ox+p.width > maxx) maxx = p.ox+p.width;
            if (p.oy > maxy) maxy = p.oy;
        }
        box = CGRectMake(minx, miny, maxx-minx, maxy-miny);
    }
    return box;
}
- (NSInteger)boundingBoxSurface {
    CGRect box = [self getBoundingBox];
    return box.size.width * box.size.height;
}

@end






@interface SimpleDivider(private)
- (void)explorePixelAtRow:(int)row Col:(int)col From:(int)dir;
- (void)analyzeBoundaries;
@end

@implementation SimpleDivider

@synthesize resImage=_resImage;
@synthesize blobs=_blobs;

- (NSArray*)divide:(UIImage*)img{
    CGImageRef imageRef = [img CGImage];
    NSUInteger originW = CGImageGetWidth(imageRef);
    NSUInteger originH = CGImageGetHeight(imageRef);
    float surface = 800*600;
    _ratio = sqrt(surface / (originW*originH));
    _width = _ratio * originW;
    _height = _ratio * originH;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    _bytesPerPixel = 1;
    _rawData = malloc(_height*_width*_bytesPerPixel);
    _markData = malloc(sizeof(bool)*_height*_width);
    NSUInteger bytesPerRow = _bytesPerPixel*_width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(_rawData,_width,_height,
                                              bitsPerComponent,bytesPerRow,colorSpace,
                                              kCGImageAlphaNone);

    // Draw white background
    CGContextSetGrayFillColor(context, 1, 1);
    CGContextFillRect(context, CGRectMake(0, 0, _width, _height));
    // Draw img in center
    CGContextDrawImage(context,CGRectMake(5,5,_width-10,_height-10),imageRef);

    // Predefine the border of image
    for (int row = 0; row < _height; ++row) {
        for (int col = 0; col < _width; ++col) {
            NSUInteger index = row * _width + col;
            if(row < 9 || col < 9 || row >= _height-5 || col >= _width-5) _markData[index] = true;
            else _markData[index] = false;
        }
    }

    // Preprocess, mark image pixels to content(1) or background(0).
#pragma Process with recursion
#ifdef recursion
    [self explorePixelAtRow:9 Col:9 From:0];
#endif

#pragma Process with loop
#ifdef loop
    NSUInteger markId, byteId;
    int gray;
    // Loop from top_left to bottom_right
    for (int row = 4; row < _height-5; ++row) {
        for (int col = 4; col < _width-5; ++col) {
            markId = row * _width + col;
            if(_markData[markId]) continue;
            byteId = markId * _bytesPerPixel;
            gray = _rawData[byteId];

            // One pixel marked in the top/left pixel
            if(gray > 220 && (_markData[markId-1] || _markData[markId-_width]))
                _markData[markId] = true;
        }
    }
    // Loop from bottom_right to top_left
    for (int row = _height-6; row >= 4; --row) {
        for (int col = _width-6; col >= 4; --col) {
            markId = row * _width + col;
            if(_markData[markId]) continue;
            byteId = markId * _bytesPerPixel;
            gray = _rawData[byteId];
            
            // One pixel marked in the bottom/right pixel
            if(gray > 220 && (_markData[markId+1] || _markData[markId+_width]))
                _markData[markId] = true;
        }
    }
    // Loop from bottom_left to top_right
    for (int row = _height-6; row >= 4; --row) {
        for (int col = 4; col < _width-5; ++col) {
            markId = row * _width + col;
            if(_markData[markId]) continue;
            byteId = markId * _bytesPerPixel;
            gray = _rawData[byteId];
            
            // One pixel marked in the bottom/left pixel
            if(gray > 220 && (_markData[markId-1] || _markData[markId+_width]))
                _markData[markId] = true;
        }
    }
    // Loop from top_right to bottom_left
    for (int row = 4; row < _height-5; ++row) {
        for (int col = _width-6; col >= 4; --col) {
            markId = row * _width + col;
            if(_markData[markId]) continue;
            byteId = markId * _bytesPerPixel;
            gray = _rawData[byteId];
            
            // One pixel marked in the top/right pixel
            if(gray > 220 && (_markData[markId+1] || _markData[markId-_width]))
                _markData[markId] = true;
        }
    }
#endif
    
    // Analyse mark data to find out all the boundaries of manga bloc
    [self analyzeBoundaries];

#pragma Generation of test image
#ifdef TEST
    // For test
    // Set all content pixel to black
    for (int row = 0; row < _height; ++row) {
        for (int col = 0; col < _width; ++col) {
            NSUInteger index = row * _width + col;
            if(!_markData[index]) _rawData[index] = 0;
        }
    }
    
    CGContextRef ctxTest = CGBitmapContextCreate(_rawData,320,480,
                                                 bitsPerComponent,_bytesPerPixel*320,colorSpace,
                                                 kCGImageAlphaNone);
    // Draw Test Image
    CGContextDrawImage(ctxTest,CGRectMake(0,0,320,480),CGBitmapContextCreateImage(context));
    float rx = 320.0/_width, ry = 480.0/_height;
    for (Blob* blob in _blobs) {
        CGContextSetGrayStrokeColor(ctxTest, (float)random()/RAND_MAX, 1);
        CGRect box = [blob getBoundingBox];
        int w = box.size.width*rx, h = box.size.height*ry;
        int x = box.origin.x*rx, y = 480-box.origin.y*ry-h;
        CGContextStrokeRect(ctxTest, CGRectMake(x, y, w, h));
        /*
        NSArray *profils = [blob profils];
        CGContextBeginPath (ctxTest);
        for (Profil *p in profils) {
            int y = 480-p.oy*ry;
            CGContextMoveToPoint(ctxTest, p.ox*rx, y);
            CGContextAddLineToPoint(ctxTest, (p.ox+p.width)*rx, y);
        }
        CGContextStrokePath(ctxTest);
        */
    }
    
    imageRef = CGBitmapContextCreateImage(ctxTest);
    _resImage = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(ctxTest);
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
#endif
    free(_rawData);
    free(_markData);
    
    return [self getROIs];
}

- (NSArray*)getROIs {
    if([_blobs count] == 0 || _ratio <= 0)
        return [NSArray array];
    NSMutableArray* rois = [NSMutableArray arrayWithCapacity:[_blobs count]];
    for(int i = 0; i < [_blobs count]; ++i) {
        CGRect box = [[_blobs objectAtIndex:i] getBoundingBox];
        box.origin.x = (box.origin.x-5) / _ratio - 20;
        box.origin.y = (box.origin.y-5) / _ratio - 20;
        box.size.width = box.size.width / _ratio + 40;
        box.size.height = box.size.height / _ratio + 40;
        [rois addObject:[NSValue valueWithCGRect:box]];
    }
    return [NSArray arrayWithArray:rois];
}

- (void)explorePixelAtRow:(int)row Col:(int)col From:(int)dir{
    NSUInteger markId = (row * _width) + col;
    
    // Pixel marked
    if(_markData[markId]) return;
    else {
        NSUInteger byteId = markId * _bytesPerPixel;
        int gray = _rawData[byteId];
    // Pixel considered like a pixel of content, stop the exploring process with this pixel
        if(gray < 200) return;
    // Pixel background, explore to the 4 neighbor pixels
        else {
            _markData[markId] = true;
            _rawData[byteId] = 255;
            // Top pixel
            //if(dir != 0) [self explorePixelAtRow:row-1 Col:col From:2];
            // Right pixel
            if(dir != 1) [self explorePixelAtRow:row Col:col+1 From:3];
            // Bottom pixel
            if(dir != 2) [self explorePixelAtRow:row+1 Col:col From:0];
            // Left pixel
            if(dir != 3) [self explorePixelAtRow:row Col:col-1 From:1];
            return;
        }
    }
}

- (void)analyzeBoundaries {
    NSMutableArray* liveBlobs = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray* fixedBlobs = [NSMutableArray arrayWithCapacity:10];
    int seuil = _width*_height/15;
    for (int row = 0; row < _height; ++row) {
        // Mark all live blobs to unchecked
        for (Blob* blob in liveBlobs)
            blob.connected = false;
        int i = 0;
        
        for (int col = 0; col < _width; ++col) {
            NSUInteger index = row * _width + col;
            // Content profil start point found, construction of profil and check connectivity with active blobs
            if(!_markData[index]) {
                int width = 1, ox = col, oy = row;
                // Determing the width of profil
                while ((++col) < _width && !_markData[row*_width+col]) {
                    width++;
                }
                // Create profil
                Profil* curr = [[Profil alloc] initWithPointOx:ox Oy:oy andWidth:width];
                
                // First profil, automatically create the blob
                if ([liveBlobs count] == 0) {
                    Blob* newblob = [[Blob alloc] initWithProfil:curr];
                    [liveBlobs addObject:newblob];
                    continue;
                }
                
                // Roll back one blob to check new profil connectivity
                if (i > 0) --i;
                // Check connectivity
                for (; i < [liveBlobs count]; ++i) {
                    Blob* blob = [liveBlobs objectAtIndex:i];
                    int relation = [blob checkConnect:curr];
                    // Blob at the right of the profil, no need to proceed any further
                    if (relation == RIGHT) {
                        // No connection, create a new blob
                        if (curr.pblob == nil) {
                            Blob* newblob = [[Blob alloc] initWithProfil:curr];
                            [liveBlobs insertObject:newblob atIndex:[liveBlobs indexOfObject:blob]];
                        }
                        break;
                    }
                    // Blob connecting with profil
                    else if (relation == CONNECT) {
                        Blob* old = curr.pblob;
                        [blob combien:curr];
                        // Already connected with another blob, delete it
                        if (old != nil) {
                            [liveBlobs removeObject:old];
                            --i;
                        }
                    }
                }
            }
        }
        
        // Verification for all unchecked live blobs, kill it or put it in the fixed blobs list
        for (int j = 0; j < [liveBlobs count]; ++j) {
            Blob* blob = [liveBlobs objectAtIndex:j];
            if(!blob.connected || row == _height-1) {
                // If blob small than seuil, ignore it
                if([blob boundingBoxSurface] >= seuil) 
                    [fixedBlobs addObject:blob];
                // Remove from live blobs list
                [liveBlobs removeObjectAtIndex:(j--)];
            }
        }
    }
    _blobs = [NSArray arrayWithArray:fixedBlobs];
}

@end