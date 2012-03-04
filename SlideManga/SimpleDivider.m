//
//  SimpleDivider.m
//  SlideManga
//
//  Created by LING HUABIN on 28/02/12.
//  Copyright (c) 2012 pandamicro.co.cc All rights reserved.
//

#import "SimpleDivider.h"

@interface SimpleDivider(private)
- (void)explorePixelAtRow:(int)row Col:(int)col From:(int)dir;
@end

@implementation SimpleDivider

@synthesize resImage=_resImage;

- (NSArray*)divide:(UIImage*)img{
    CGImageRef imageRef = [img CGImage];
    NSUInteger originW = CGImageGetWidth(imageRef);
    NSUInteger originH = CGImageGetHeight(imageRef);
    _width = 1040;
    _height = ((float)1000/originW)*originH + 40;
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
    CGContextDrawImage(context,CGRectMake(20,20,_width-40,_height-40),imageRef);
    
    // Preprocess, mark image pixels to content(1) or background(0). Start with pixel (0,0)
    for (int row = 0; row < _height; ++row) {
        for (int col = 0; col < _width; ++col) {
            NSUInteger index = row * _width + col;
            // Predefine the border of image
            if(row < 19 || col < 19 || row >= _height-20 || col >= _width-20) _markData[index] = false;
            else _markData[index] = true;
        }
    }
    [self explorePixelAtRow:19 Col:19 From:0];
    
    // Analyse mark data to find out all the boundaries of manga bloc
    
    // For test
    // Set all content pixel to black
    for (int row = 0; row < _height; ++row) {
        for (int col = 0; col < _width; ++col) {
            NSUInteger index = row * _width + col;
            if(_markData[index]) _rawData[index] = 0;
        }
    }
    
    CGContextRef ctxTest = CGBitmapContextCreate(_rawData,320,480,
                                                 bitsPerComponent,_bytesPerPixel*320,colorSpace,
                                                 kCGImageAlphaNone);
    
    CGContextDrawImage(ctxTest,CGRectMake(0,0,320,480),CGBitmapContextCreateImage(context));
    imageRef = CGBitmapContextCreateImage(ctxTest);
    _resImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctxTest);
    CGContextRelease(context);
    free(_rawData);
    free(_markData);
    
    return NULL;
}

- (void)explorePixelAtRow:(int)row Col:(int)col From:(int)dir{
    NSUInteger markId = (row * _width) + col;
    
    // Pixel marked
    if(!_markData[markId]) return;
    else {
        NSUInteger byteId = markId * _bytesPerPixel;
        int gray = _rawData[byteId];
    // Pixel considered like a pixel of content, stop the exploring process with this pixel
        if(gray < 200) return;
    // Pixel background, explore to the 4 neighbour pixels
        else {
            _markData[markId] = false;
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

@end
