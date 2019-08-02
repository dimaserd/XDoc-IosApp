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

#import "SmartIDImage+CPP.h"
#import "SmartIDQuadrangle+CPP.h"

@implementation SmartIDImage {
    se::smartid::Image image_;
}

- (se::smartid::Image) wrapSampleBuffer:(CMSampleBufferRef)buff {
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buff);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    uint8_t *basePtr = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    const int width = (int)CVPixelBufferGetWidth(imageBuffer);
    const int height = (int)CVPixelBufferGetHeight(imageBuffer);
    
    unsigned char * copiedData = reinterpret_cast<unsigned char *>(malloc((width * 3 * height)));
    
    size_t offset = 0;
    uint8_t *rowPtr = copiedData;
    for(size_t i = 0; i < height; ++i) {
        uint8_t *colPtr = rowPtr;
        for(size_t j = 0; j < width; ++j) {
            for(int ch = 0; ch < 3; ++ch) {
                *(colPtr + ch) = basePtr[offset + 2 - ch];
            }
            offset += 4;
            colPtr += 3;
        }
        rowPtr += width * 3;
    }
    auto ret = se::smartid::Image(copiedData, width * 3 * height,
                                  width,
                                  height,
                                  width * 3,
                                  3);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    delete[] copiedData;
    return ret;
}

- (se::smartid::Image) wrapUIImage:(UIImage *)img {
    CGImageRef cgImage = [img CGImage];
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef dataRef = CGDataProviderCopyData(provider);
    const uint8_t *data = CFDataGetBytePtr(dataRef);
    
    unsigned char * copiedData = reinterpret_cast<unsigned char *>(malloc((CGImageGetWidth(cgImage) * 3 * CGImageGetHeight(cgImage))));
    
    size_t offset = 0;
    uint8_t *rowPtr = copiedData;
    for(size_t i = 0; i < CGImageGetHeight(cgImage); ++i) {
        uint8_t *colPtr = rowPtr;
        for(size_t j = 0; j < CGImageGetWidth(cgImage); ++j) {
            for (int ch = 0; ch < 3; ++ch) {
                *(colPtr + ch) = data[offset + ch];
            }
            offset += 4;
            colPtr += 3;
        }
        rowPtr += CGImageGetWidth(cgImage) * 3;
    }
    CFRelease(dataRef);
    auto ret = se::smartid::Image(copiedData, CGImageGetWidth(cgImage) * 3 * CGImageGetHeight(cgImage),
                                  static_cast<int>(CGImageGetWidth(cgImage)),
                                  static_cast<int>(CGImageGetHeight(cgImage)),
                                  static_cast<int>(CGImageGetWidth(cgImage) * 3),
                                  3);
    delete[] copiedData;
    return ret;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        image_ = [self wrapUIImage:image];
    }
    return self;
}

- (instancetype)initWithBuffer:(CMSampleBufferRef)buff {
    if (self = [super init]) {
        image_ = [self wrapSampleBuffer:buff];
    }
    return self;
}

- (instancetype)initWithCPPInstance:(const se::smartid::Image &)image {
    if (self = [super init]) {
        image_ = image;
    }
    return self;
}

- (se::smartid::Image &)getUnwrapped {
    return image_;
}

- (SmartIDImage *)cropWithQuadrangle:(SmartIDQuadrangle *)quad {
    se::smartid::Image cpp_img = image_;
    const se::smartid::Quadrangle cpp_quad = [quad getUnwrapped];
    try {
        cpp_img.Crop(cpp_quad);
    } catch (std::exception e) {
        return nil;
    }
    return [[SmartIDImage alloc] initWithCPPInstance: cpp_img];
}

- (SmartIDImage *)cropWithQuadrangle:(SmartIDQuadrangle *)quad toSize:(CGSize)size {
    se::smartid::Image cpp_img = image_;
    const se::smartid::Quadrangle cpp_quad = [quad getUnwrapped];
    try {
        cpp_img.Crop(cpp_quad, size.width, size.height);
    } catch (std::exception e) {
        return nil;
    }
    return [[SmartIDImage alloc] initWithCPPInstance: cpp_img];
}

- (void)maskImageRegionRectangle:(CGRect)rect {
    image_.MaskImageRegionRectangle(se::smartid::Rectangle(rect.origin.x,
                                                           rect.origin.y,
                                                           rect.size.width,
                                                           rect.size.height));
}

- (void)maskImageRegionQuadrangle:(SmartIDQuadrangle *)quad {
    auto cpp_quad = [quad getUnwrapped];
    image_.MaskImageRegionQuadrangle(cpp_quad);
}

-(void)maskImageRegionQuadrangle:(SmartIDQuadrangle *)quad withExpand:(int)expand {
    auto cpp_quad = [quad getUnwrapped];
    image_.MaskImageRegionQuadrangle(cpp_quad, expand);
}



- (nonnull UIImage *) uiImage {
    uint8_t *data = new uint8_t[image_.width * image_.height * 4];
    
    size_t offset = 0;
    uint8_t *rowPtr = reinterpret_cast<uint8_t *>(image_.data);
    for(size_t i = 0; i < image_.height; ++i) {
        uint8_t *colPtr = rowPtr;
        
        for(size_t j = 0; j < image_.width; ++j) {
            for(size_t ch = 0; ch < 3; ++ch) {
                data[offset + ch] = *(colPtr + ch);
            }
            data[offset + 3] = UINT8_MAX;
            
            offset += 4;
            colPtr += 3;
        }
        
        rowPtr += image_.stride;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(
                                                 &data[0],
                                                 image_.width,
                                                 image_.height,
                                                 8,
                                                 4 * image_.width,
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

@end
