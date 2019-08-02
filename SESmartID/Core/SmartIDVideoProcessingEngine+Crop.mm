/**
 Copyright (c) 2012-2018, Smart Engines Ltd
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 * Neither the name of the Smart Engines Ltd nor the names of its
 contributors may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SmartIDVideoProcessingEngine+Crop.h"
#include <smartIdEngine/smartid_engine.h>

@implementation smartIDVideoProcessingEngine (Crop)

+ (UIImage *) createUIImageFromSmartIDImage:(const se::smartid::Image &)img {
    uint8_t *data = new uint8_t[img.width * img.height * 4];
    
    size_t offset = 0;
    uint8_t *rowPtr = reinterpret_cast<uint8_t *>(img.data);
    for(size_t i = 0; i < img.height; ++i) {
        uint8_t *colPtr = rowPtr;
        
        for(size_t j = 0; j < img.width; ++j) {
            for(size_t ch = 0; ch < 3; ++ch) {
                data[offset + ch] = *(colPtr + 2 - ch); // BGR->RGB
            }
            data[offset + 3] = UINT8_MAX;
            
            offset += 4;
            colPtr += 3;
        }
        
        rowPtr += img.stride;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
                                                 &data[0],
                                                 img.width,
                                                 img.height,
                                                 8,
                                                 4 * img.width,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    UIImage *ret = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    delete[] data;
    
    return ret;
}

+ (const se::smartid::Quadrangle) wrapQuadrangle:(SmartIDQuadrangle *)quad {
    se::smartid::Quadrangle smartIDQuad;
    for (int i = 0; i < 4; ++i) {
        smartIDQuad[i].x = [quad getPointAtIndex:i].x;
        smartIDQuad[i].y = [quad getPointAtIndex:i].y;
    }
    return smartIDQuad;
}

+ (se::smartid::Image) wrapUIImage:(UIImage *)img shouldCopy:(BOOL)copy {
    CGImageRef cgImage = [img CGImage];
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef dataRef = CGDataProviderCopyData(provider);
    const uint8_t *data = CFDataGetBytePtr(dataRef);
    
    unsigned char * copiedData = reinterpret_cast<unsigned char *>(malloc((CGImageGetWidth(cgImage) * 3 * CGImageGetHeight(cgImage))));
    
    // RGBA or BGRA
    CGBitmapInfo alphaInfo = CGImageGetBitmapInfo(cgImage) & kCGBitmapAlphaInfoMask;
    bool isRgb = ((alphaInfo == kCGImageAlphaNoneSkipFirst) ||
                  (alphaInfo == kCGImageAlphaNoneSkipLast));
    
    size_t offset = 0;
    uint8_t *rowPtr = copiedData;
    for(size_t i = 0; i < CGImageGetHeight(cgImage); ++i) {
        uint8_t *colPtr = rowPtr;
        for(size_t j = 0; j < CGImageGetWidth(cgImage); ++j) {
            for(int ch = 0; ch < 3; ++ch) {
                if(isRgb == true) {
                    *(colPtr + ch) = data[offset + ch];
                } else {
                    // FIXME: isRgb flag is wrong
                    *(colPtr + ch) = data[offset + ch];
                }
            }
            offset += 4;
            colPtr += 3;
        }
        rowPtr += CGImageGetWidth(cgImage) * 3;
    }
    CFRelease(dataRef);
    auto ret = se::smartid::Image(copiedData, CGImageGetWidth(cgImage) * 3 * CGImageGetHeight(cgImage),
                                  CGImageGetWidth(cgImage),
                                  CGImageGetHeight(cgImage),
                                  CGImageGetWidth(cgImage) * 3,
                                  3);
    delete[] copiedData;
    return ret;
}

+ (UIImage *) cropImage:(UIImage *)image withQuadrangle:(SmartIDQuadrangle *)quad {
    auto smartIDImg = [smartIDVideoProcessingEngine wrapUIImage:image shouldCopy:YES];
    const auto smartIDQuad = [smartIDVideoProcessingEngine wrapQuadrangle:quad];
    NSLog(@"cropping %d x %d image..", smartIDImg.width, smartIDImg.height);
    smartIDImg.Crop(smartIDQuad);
    return [smartIDVideoProcessingEngine createUIImageFromSmartIDImage:smartIDImg];
}

@end
