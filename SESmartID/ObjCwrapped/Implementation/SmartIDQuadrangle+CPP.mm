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

#import "SmartIDQuadrangle+CPP.h"

@implementation SmartIDQuadrangle {
    std::unique_ptr<se::smartid::Quadrangle> quadrangle_;
}

#pragma mark - C++

- (instancetype)init {
    if (self = [super init]) {
        if (quadrangle_.get() == nullptr) {
            quadrangle_.reset(new se::smartid::Quadrangle());
        }
    }
    return self;
}

- (instancetype) initWith:(CGRect)rect andSize:(CGSize)size {
    if (self = [self init]) {
        quadrangle_->SetPoint(0, se::smartid::Point(rect.origin.x, rect.origin.y));
        quadrangle_->SetPoint(1, se::smartid::Point(rect.origin.x + rect.size.width, rect.origin.y));
        quadrangle_->SetPoint(2, se::smartid::Point(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
        quadrangle_->SetPoint(3, se::smartid::Point(rect.origin.x, rect.origin.y + rect.size.height));
    }
    return self;
}

- (instancetype)initWithCPPInstance:(const se::smartid::Quadrangle &)quadrangle {
    if (self = [super init]) {
        quadrangle_.reset(new se::smartid::Quadrangle(quadrangle));
    }
    return self;
}

- (se::smartid::Quadrangle &)getUnwrapped {
    return *quadrangle_;
}

#pragma mark - wrap

- (void) setPoint:(CGPoint)point atIndex:(NSUInteger)i {
    quadrangle_->SetPoint(static_cast<int>(i), { point.x, point.y });
}

- (CGPoint) getPointAtIndex:(NSUInteger)i {
    return CGPointMake(quadrangle_->GetPoint(static_cast<int>(i)).x,
                       quadrangle_->GetPoint(static_cast<int>(i)).y);
}

- (void) normalize:(CGSize)viewSize {
    
//    UIInterfaceOrientation current = [UIApplication sharedApplication].statusBarOrientation;
//    for (size_t i = 0; i < 4; ++i) {
//        CGPoint cur = [self getPointAtIndex:i];
//        if (UIInterfaceOrientationIsLandscape(current)) {
//            cur.x /= self.imageSize.width;
//            cur.x *= viewSize.width;
//            cur.y /= self.imageSize.height;
//            cur.y *= viewSize.height;
//        } else {
//            cur.x /= self.imageSize.height;
//            cur.x *= viewSize.width;
//            cur.y /= self.imageSize.width;
//            cur.y *= viewSize.height;
//        }
//        [self setPoint:cur atIndex:i];
//    }
//
//    if (current == UIInterfaceOrientationLandscapeRight) {
//        if (self.quadOrientation == UIDeviceOrientationPortrait) {
//            [self rotate90cw:CGSizeMake(viewSize.height, viewSize.width)];
//        }
//    } else if (current == UIInterfaceOrientationLandscapeLeft) {
//        if (self.quadOrientation == UIDeviceOrientationPortrait) {
//            [self rotate90ccw:CGSizeMake(viewSize.height, viewSize.width)];
//        }
//    } else {
//        if (self.quadOrientation == UIDeviceOrientationLandscapeLeft) {
//            [self rotate90ccw:CGSizeMake(viewSize.width, viewSize.height)];
//        } else if (self.quadOrientation == UIDeviceOrientationLandscapeRight) {
//            [self rotate90cw:CGSizeMake(viewSize.width, viewSize.height)];
//        }
//    }
    return;
}

- (void) rotate90cw:(CGSize)viewSize {
    for (size_t i = 0; i < 4; ++i) {
        CGPoint cur = [self getPointAtIndex:i];
        cur.x = viewSize.height - cur.x;
        [self setPoint:CGPointMake(cur.y, cur.x) atIndex: i];
    }
}

- (void) rotate90ccw:(CGSize)viewSize {
    for (size_t i = 0; i < 4; ++i) {
        CGPoint cur = [self getPointAtIndex:i];
        cur.y = viewSize.width - cur.y;
        [self setPoint:CGPointMake(cur.y, cur.x) atIndex: i];
    }
}

- (void) shiftPoints:(CGPoint)offsets {
    for (uint8_t i = 0; i < 4; ++i) {
        [self setPoint:CGPointMake([self getPointAtIndex:i].x + offsets.x,
                                   [self getPointAtIndex:i].y + offsets.y) atIndex:i];
    }
}

static CGSize CGSizeMakeAspectFill(const CGSize aspectRatio, const CGSize minSize) {
    CGSize aspectFillSize = CGSizeMake(minSize.width, minSize.height);
    const CGFloat minWidth = minSize.width / aspectRatio.width;
    const CGFloat minHeight = minSize.height / aspectRatio.height;
    if (minHeight > minWidth) {
        aspectFillSize.width = minHeight * aspectRatio.width;
    } else {
        aspectFillSize.height = minWidth * aspectRatio.height;
    }
    return aspectFillSize;
}

- (void) preprocesssWithFrameSize:(CGSize)frameSize
                       sourceSize:(CGSize)ssize
                deviceOrientation:(UIDeviceOrientation)dOrientation
                          offsets:(CGPoint)offsets {
    [self shiftPoints: offsets];
    
    const UIInterfaceOrientation current = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(current)) {
        ssize = CGSizeMake(ssize.height, ssize.width);
    }
    
    const CGSize aspectFillFrameSize = CGSizeMakeAspectFill(ssize, frameSize);
    
    for (size_t i = 0; i < 4; ++i) {
        CGPoint cur = [self getPointAtIndex:i];
        
        cur.x /= ssize.width;
        cur.x *= aspectFillFrameSize.width;
        cur.y /= ssize.height;
        cur.y *= aspectFillFrameSize.height;
        
        [self setPoint:cur atIndex:i];
    }
    
    const CGPoint aspectDifference = CGPointMake((frameSize.width - aspectFillFrameSize.width) / 2,
                                                 (frameSize.height - aspectFillFrameSize.height) / 2);
    
    if (current == UIInterfaceOrientationLandscapeRight) {
        if (dOrientation == UIDeviceOrientationPortrait) {
            [self rotate90cw:CGSizeMake(frameSize.height, frameSize.width)];
        }
        [self shiftPoints:CGPointMake(aspectDifference.x, -aspectDifference.y)];
    } else if (current == UIInterfaceOrientationLandscapeLeft) {
        if (dOrientation == UIDeviceOrientationPortrait) {
            [self rotate90ccw:CGSizeMake(frameSize.height, frameSize.width)];
        }
        [self shiftPoints:CGPointMake(aspectDifference.x, aspectDifference.y)];
    } else {
        if (dOrientation == UIDeviceOrientationLandscapeLeft) {
            [self rotate90ccw:CGSizeMake(frameSize.width, frameSize.height)];
            [self shiftPoints:CGPointMake(-aspectDifference.x, aspectDifference.y)];
        } else if (dOrientation == UIDeviceOrientationLandscapeRight) {
            [self rotate90cw:CGSizeMake(frameSize.width, frameSize.height)];
            [self shiftPoints:CGPointMake(aspectDifference.x, -aspectDifference.y)];
        } else {
            [self shiftPoints:CGPointMake(aspectDifference.x, aspectDifference.y)];
        }
    }
}


- (UIBezierPath *)bezierPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint first = [self getPointAtIndex:0];
    [path moveToPoint:CGPointMake(first.x, first.y)];
    
    for (int i = 0; i < 4; ++i) {
        CGPoint next = [self getPointAtIndex:(i + 1) % 4];
        [path addLineToPoint:next];
    }
    return path;
}

@end
